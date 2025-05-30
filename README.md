# BayesianHierarchialModelling
Exploring the Relationship Between Depression Rates and Voting Outcomes in the 2024 U.S. Election: A Bayesian Hierarchical Modelling Approach
# Exploring the Relationship Between Depression Rates and Voting Outcomes in the 2024 U.S. Election: A Bayesian Hierarchical Modelling Approach

*A comprehensive Bayesian statistical analysis investigating the association between county-level depression prevalence and Republican voting patterns in the 2024 U.S. Presidential Election*

IMAGES

## 🎯 Project Overview

This project examines whether higher depression rates in U.S. counties are associated with increased support for Donald Trump in the 2024 presidential election, while controlling for demographic factors and accounting for state-level variations through sophisticated Bayesian hierarchical modeling.

### Key Findings

**Main Result**: Each 1% increase in depression prevalence corresponds to an estimated **1.85 percentage point increase** in GOP vote share (95% CI: [1.19, 2.53]), after adjusting for race, gender, and population size.

**State Variation**: The relationship between depression and voting behavior varies significantly across states, with some states showing stronger positive associations and others showing negligible or even negative relationships.

## 📊 Dataset

- **Scope**: 3,107 counties across 50 U.S. states
- **Variables**: 
  - County-level depression prevalence rates
  - 2024 Presidential election voting outcomes
  - Demographic composition (race, gender)
  - Population statistics

## 🔬 Methodology

### Statistical Approach
- **Framework**: Bayesian hierarchical modeling using the `brms` package
- **Family**: Gaussian regression with identity link
- **Variance Modeling**: Population-weighted residual variance
- **Model Comparison**: Leave-One-Out Cross-Validation (LOO)

### Model Evolution
1. **Exploratory OLS** - Initial relationship assessment
2. **Bayesian Linear Regression** - Baseline model with demographic controls
3. **Hierarchical Random Intercept** - State-level variation in baseline support
4. **Hierarchical Random Intercept + Slope** - State-specific depression effects *(Best Model)*

## 🏗️ Repository Structure

```
├── ASM.R                     # Main analysis script
├── data/
│   └── data.csv             # County-level dataset
├── results/
│   ├── figures/             # Generated visualizations
│   └── models/              # Saved model objects
├── README.md
└── requirements.txt         # R package dependencies
```

## 🚀 Getting Started

### Prerequisites

```r
# Install required packages
install.packages(c(
  "brms",        # Bayesian regression models
  "ggplot2",     # Data visualization
  "dplyr",       # Data manipulation
  "readr",       # Data import
  "bayesplot",   # MCMC diagnostics
  "patchwork",   # Multiple plots
  "loo",         # Model comparison
  "skimr",       # Data summary
  "rstan",       # Stan interface
  "GGally"       # Pairwise plots
))
```

### Running the Analysis

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/depression-voting-analysis.git
   cd depression-voting-analysis
   ```

2. **Execute the main script**
   ```r
   source("ASM.R")
   ```

3. **Key outputs will include**:
   - Model comparison statistics
   - State-specific effect visualizations
   - Posterior predictive checks
   - Diagnostic plots

## 📈 Key Visualizations

### State-Specific Depression Effects
Our central finding visualizes how the depression-voting relationship varies by state:

- **Positive effects**: States like Texas show stronger associations between depression and Republican support
- **Negative effects**: States like New York show opposite or negligible relationships
- **Uncertainty**: Confidence intervals reflect varying sample sizes across states

### Model Diagnostics
- Posterior predictive checks confirm good model fit
- Convergence diagnostics (R̂ = 1.00) indicate reliable sampling
- LOO comparison validates hierarchical model superiority

## 🎯 Results Summary

| Predictor | Effect Size | 95% Credible Interval | Interpretation |
|-----------|-------------|----------------------|----------------|
| **Depression Prevalence** | +1.85 | [1.19, 2.53] | 1% ↑ depression → 1.85pp ↑ GOP vote |
| **Race (% White)** | +0.60 | [0.57, 0.63] | 1% ↑ white → 0.60pp ↑ GOP vote |
| **Gender (% Male)** | +103.56 | [88.77, 117.74] | 1pp ↑ male → 1.04pp ↑ GOP vote |

### State-Level Variation
- **Random Intercept SD**: 39.20 (substantial baseline differences)
- **Random Slope SD**: 2.08 (moderate variation in depression effects)
- **Correlation**: -0.96 (states with higher baseline GOP support show weaker depression effects)

## 🔍 Model Comparison

| Model | ELPD Difference | Standard Error |
|-------|----------------|----------------|
| **Hierarchical (Intercept + Slope)** | 0.0 | 0.0 |
| Hierarchical (Intercept Only) | -79.4 | 17.9 |
| Bayesian Linear Regression | -1118.7 | 49.4 |

The full hierarchical model significantly outperforms simpler alternatives.

## 💡 Technical Highlights

### Advanced Features
- **Population weighting**: `sigma ~ scale(log(TOT_POP))` accounts for county size differences
- **Convergence optimization**: `adapt_delta = 0.95` ensures stable sampling
- **Comprehensive diagnostics**: Multiple posterior predictive checks validate model assumptions

### Computational Details
- **Sampling**: 4 chains × 4000 iterations (2000 warmup)
- **Convergence**: All R̂ ≈ 1.00
- **Effective samples**: High ESS across all parameters

## 🔮 Future Extensions

### Methodological Improvements
- **Informative priors**: Especially for sparsely sampled states
- **Non-linear models**: Investigate interaction effects and threshold behaviors
- **Alternative distributions**: Beta regression for bounded proportions

### Additional Analyses
- **Causal inference**: Instrumental variables or natural experiments
- **Temporal dynamics**: Panel data across multiple elections
- **Mechanism exploration**: Mediation analysis through economic factors

## 📚 Dependencies

### Core Packages
- `brms` (≥2.19.0) - Bayesian modeling
- `ggplot2` (≥3.4.0) - Visualization
- `dplyr` (≥1.1.0) - Data manipulation
- `rstan` (≥2.26.0) - Stan interface

### Full dependency list available in `requirements.txt`


## 🤝 Contributing

Contributions are welcome! Please feel free to:
- Report bugs or issues
- Suggest methodological improvements
- Add additional analyses
- Improve documentation



## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*This analysis demonstrates advanced Bayesian statistical modeling techniques applied to contemporary political and pub
