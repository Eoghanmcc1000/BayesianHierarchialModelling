# BayesianHierarchialModelling
#Exploring the Relationship Between Depression Rates and Voting Outcomes in the 2024 U.S. Election: A Bayesian Hierarchical Modelling Approach


install.packages("brms")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("readr")
install.packages("bayesplot")
install.packages("patchwork")
install.packages("loo")
install.packages("skimr")
install.packages("rstan", dependencies = TRUE)

# Load libraries
library(brms)       # Bayesian regression models
library(ggplot2)    # Beautiful plotting
library(dplyr)      # Data manipulation
library(readr)      # Read in CSV easily
library(bayesplot)  # MCMC diagnostics and nicer plots
library(patchwork)  # Arrange multiple plots easily
library(loo)        # Model comparison (LOO-CV, WAIC)
library(skimr)
library(rstan)
install.packages("GGally")
library(GGally)


data <- read_csv("data.csv")

dplyr::glimpse(data)   # Quick overview of structure
head(data)      # First 6 rows

#1. Restate Objective Clearly
#Goal: Check if Trump voting % (or Republican majority) is associated with higher depression rates, controlling for race and state effects.
#We’ll need models that adjust for confounders and hierarchical structure (state/county).

data %>%
  dplyr::select(per_gop, Crude.Prevalence.Estimate, race) %>%
  summary()
skim(data)

# Create proportion of male residents in county
data <- data %>%
  mutate(prop_male = TOT_MALE / (TOT_MALE + TOT_FEMALE))


# Basic Histograms To check distributions

ggplot2::ggplot(data, aes(x = per_gop)) + geom_histogram(bins = 15) + ggtitle("Distribution of % GOP votes")
ggplot2::ggplot(data, aes(x = Crude.Prevalence.Estimate)) + geom_histogram(bins = 15) + ggtitle("Distribution of Depression Rates")
ggplot2::ggplot(data, aes(x = race)) + geom_histogram(bins = 15) + ggtitle("Distribution of Race (White %)")

ggplot(data, aes(x = prop_male)) +
  geom_histogram(bins = 15) +
  ggtitle("Distribution of Gender (Proportion Male)") +
  theme_minimal()

median(data$per_gop, na.rm = TRUE)


# Scatterplots To inspect relationships:
# OLS
ggplot(data, aes(x = Crude.Prevalence.Estimate, y = per_gop)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  ggtitle("% GOP vs Depression")

ggplot(data, aes(x = race, y = per_gop)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  ggtitle("% GOP vs Race (White %)")

# Scatterplot: Gender balance vs Trump voting
ggplot(data, aes(x = prop_male, y = per_gop)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  labs(
    title = "% GOP vs Proportion Male",
    x = "Proportion Male",
    y = "Trump Vote Share (%)"
  ) +
  theme_minimal()

##########


# correlation check
cor(data$per_gop, data$Crude.Prevalence.Estimate, use = "complete.obs")
cor(data$per_gop, data$race, use = "complete.obs")
cor(data$per_gop, data$prop_male, use = "complete.obs")

# Focus on the predictors
GGally::ggpairs(
  data %>% dplyr::select(Crude.Prevalence.Estimate, race, prop_male),
  title = "Pairwise Relationships between Depression, Race, and Gender"
)

#Look at key variable relationships first.
#Focus on the main covariates related to your main research question.
#You don't need to exhaustively explore every single variable at this stage.
#(We'll handle complexities through model building.)



# State by state OLS - highlgihts we'll need to weight by sample size -----
ggplot(data, aes(x = Crude.Prevalence.Estimate, y = per_gop)) +
  geom_point(alpha = 0.5, size = 0.7) +
  geom_smooth(method = "lm", se = FALSE, col = "blue") +
  facet_wrap(~ STNAME, scales = "free_y") +
  labs(
    title = "State-wise OLS Fits: Depression vs Trump Vote %",
    x = "Depression Prevalence (%)",
    y = "Trump Vote Share (%)"
  ) +
  theme_minimal(base_size = 7)



# Bayesian Linear Regression model
#baseline_bayes <- brm(
#  formula = per_gop ~ Crude.Prevalence.Estimate + race + prop_male,
#  data = data,
#  family = gaussian(),   # same as aerobic case study
#  control = list(adapt_delta = 0.85),   # improve sampling stability (as in aerobic case study)
#  seed = 1234 # for reproducibility
#)

baseline_bayes <- brm(
  formula = bf(
    per_gop ~ Crude.Prevalence.Estimate + race + prop_male,
    sigma ~ scale(log(TOT_POP))
  ),
  data = data,
  family = gaussian(),
  control = list(adapt_delta = 0.85),
  seed = 1234
)



# View results
summary(baseline_bayes)

# Plot posterior distributions
plot(baseline_bayes)


# Random intercept model: per_gop as function of predictors + (1 | STNAME)
hierarchical_random_intercept <- brm(
  formula = bf(
    per_gop ~ Crude.Prevalence.Estimate + race + prop_male + (1 | STNAME),
    sigma ~ scale(log(TOT_POP))
  ),
  data = data,
  family = gaussian(),
  iter = 4000,          # Total iterations per chain
  warmup = 2000, 
  control = list(adapt_delta = 0.90),   # more stable sampling
  seed = 1234
)

summary(hierarchical_random_intercept)
plot(hierarchical_random_intercept)


# Extract posterior draws as a matrix
draws_matrix <- as_draws_matrix(hierarchical_random_intercept)

# Extract the random intercept samples for states
# In the matrix, random effects usually start after the fixed effects
# We find correct columns by checking dimnames
colnames(draws_matrix)

# Find which columns correspond to "r_STNAME" (state random intercepts)
state_effects <- draws_matrix[, grepl("r_STNAME", colnames(draws_matrix))]

# Convert to tidy format for plotting
#library(tidyr)

state_effects_df <- data.frame(
  sample = as.vector(state_effects),
  state = rep(gsub("r_STNAME\\[|,Intercept\\]", "", colnames(state_effects)), each = nrow(state_effects))
)

# Sort states by median random intercept
state_ordered <- state_effects_df %>%
  group_by(state) %>%
  summarise(median_effect = median(sample)) %>%
  arrange(median_effect) %>%
  pull(state)

state_effects_df$state <- factor(state_effects_df$state, levels = state_ordered)

# Boxplot of state random intercepts
library(ggplot2)

ggplot(state_effects_df, aes(x = state, y = sample)) +
  geom_boxplot(fill = "skyblue", outlier.size = 0.5) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "State-level Random Intercepts (Deviation from Average GOP %)",
    x = "State",
    y = "Random Intercept Effect"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# LOO 
# states for controlling ....

loo1 <- loo(hierarchical_random_intercept)
loo3 <- loo(baseline_bayes)
loo_compare(loo1, loo3)


# Random intercept + random slope (depression effect varies by state)
hierarchical_random_intercept_slope <- brm(
  formula = bf(
    per_gop ~ Crude.Prevalence.Estimate + race + prop_male + (Crude.Prevalence.Estimate | STNAME),
    sigma ~ scale(log(TOT_POP))
  ),
  data = data,
  family = gaussian(),
  control = list(adapt_delta = 0.95),  # higher adapt_delta for stability
  seed = 1234
)

summary(hierarchical_random_intercept_slope)
plot(hierarchical_random_intercept_slope)

# Extract random effects for states
ranef_df <- as.data.frame(ranef(hierarchical_random_intercept_slope)$STNAME)

# Create a new dataframe focusing only on the depression slopes
depression_slopes <- data.frame(
  state = rownames(ranef_df),
  slope = ranef_df$Estimate.Crude.Prevalence.Estimate
)

# Order the states by slope size
depression_slopes <- depression_slopes %>%
  arrange(slope) %>%
  mutate(state = factor(state, levels = state))  # Preserve ordering for plot

# Plot
ggplot(depression_slopes, aes(x = slope, y = state)) +
  geom_point(color = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "State-Specific Depression Effects on Trump Voting",
    x = "Depression Slope (Effect on GOP %)",
    y = "State"
  ) +
  theme_minimal()


# - - -- -  - - -- 
# Create a dataframe with slope and its credible intervals
depression_slopes <- data.frame(
  state = rownames(ranef_df),
  slope = ranef_df$Estimate.Crude.Prevalence.Estimate,
  lower = ranef_df$Q2.5.Crude.Prevalence.Estimate,
  upper = ranef_df$Q97.5.Crude.Prevalence.Estimate
)

# Order states by slope
depression_slopes <- depression_slopes %>%
  arrange(slope) %>%
  mutate(state = factor(state, levels = state))

# Plot with error bars
ggplot(depression_slopes, aes(x = slope, y = state)) +
  geom_point(color = "blue") +
  geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.3, color = "darkgrey") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "State-Specific Depression Effects on Trump Voting",
    x = "Depression Slope (Effect on GOP %)",
    y = "State"
  ) +
  theme_minimal()



# --- -- 


loo1 <- loo(hierarchical_random_intercept)
loo2 <- loo(hierarchical_random_intercept_slope)
loo3 <- loo(baseline_bayes)
loo_compare(loo1, loo2, loo3)


pp_check(hierarchical_random_intercept_slope)

# Nicer pp_check: Overlay plot
pp_check(hierarchical_random_intercept_slope, type = "dens_overlay", ndraws = 1000) +
  ggtitle("Posterior Predictive Check: Observed vs Simulated Trump Votes (%)")



# Get posterior predictive draws
yrep <- posterior_predict(hierarchical_random_intercept_slope)

# Calculate T(y) = variance of observed per_gop
T_y <- var(data$per_gop)

# Calculate T(yrep) = variance for each posterior predictive sample
T_yrep <- apply(yrep, 1, var)

# Plot
bayesplot::ppc_stat(
  y = data$per_gop,
  yrep = yrep,
  stat = "var"
) +
  ggtitle("Dispersion Check: Variance (T = var)")
