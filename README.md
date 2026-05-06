# Cranial_capacity_bayesian_analysis
Bayesian regression analysis (JAGS/MCMC) exploring how height, diet, technology, and evolutionary time predict cranial capacity across hominin species in R


# 🧠 Cranial Capacity & Hominin Evolution: A Bayesian Analysis

> Investigating the relationship between cranial capacity and evolutionary, biological, and environmental factors in hominins using Bayesian regression.

---

## 📌 Overview

This project applies a **Bayesian regression model** to explore how key factors — height, evolutionary time, technology use, and diet — relate to cranial capacity across hominin species. Rather than relying on traditional frequentist methods, this study uses **MCMC sampling via JAGS** to produce full posterior distributions, offering a probabilistic and uncertainty-aware understanding of brain evolution.

---

## 🔬 Research Questions

1. How does **diet** (carnivorous, omnivorous, fruit-based) relate to cranial capacity?
2. Do **technological advancements** (tool use) correlate with increases in brain size?
3. What role does **evolutionary time** play in cranial capacity development?
4. To what extent does **height** (as a proxy for body size) contribute to brain size variation?

---

## 📂 Repository Structure

```
├── Cranial_capacity.R                         # Main Bayesian regression model (JAGS + MCMC)
├── testing.R                                  # Model testing, R², MAE, MSE evaluation
├── Cranial_capacity.html                      # Interactive HTML visualization of results
└── Investigating_the_Relationship_...pdf      # Full research paper
```

---

## 📊 Dataset

- **Source**: [Kaggle](https://www.kaggle.com)
- **Variables**:
  | Variable | Type | Description |
  |---|---|---|
  | Cranial Capacity | Continuous | Brain volume in cm³ (dependent variable) |
  | Height | Continuous | Average stature in cm |
  | Time | Continuous | Millions of years ago (mya) |
  | Technology (Tecno) | Categorical | No / Yes / Likely |
  | Diet | Categorical | Dry Fruits / Soft Fruits / Omnivore / Carnivorous / Hard Fruits |

---

## ⚙️ Methodology

### Model
```
Cranial_Capacity_i ~ Normal(μ_i, τ)

μ_i = β0 + β1·Time + β2·Height + β3·Tecno_Yes + β4·Tecno_Likely
         + β5·Diet_SoftFruits + β6·Diet_Omnivore
         + β7·Diet_Carnivore + β8·Diet_HardFruits
```

### MCMC Configuration
- **Iterations**: 10,000 per chain
- **Chains**: 3 parallel chains
- **Burn-in**: 2,000 iterations
- **Thinning**: Every 10th sample retained
- **Convergence**: Assessed via trace plots and Gelman-Rubin statistic

---

## 📈 Key Results

| Predictor | Posterior Mean | 95% Credible Interval |
|---|---|---|
| Time (β1) | -0.142 | [-0.157, -0.128] |
| Height (β2) | 0.503 | [0.491, 0.516] |
| Technology: Yes (β3) | 1.070 | [1.032, 1.107] |
| Technology: Likely (β4) | 0.428 | [0.381, 0.484] |
| Soft Fruits Diet (β5) | 0.083 | [0.053, 0.114] |
| Omnivorous Diet (β6) | -0.523 | [-0.577, -0.477] |
| Carnivorous Diet (β7) | 0.036 | [-0.025, 0.097] |
| Hard Fruits Diet (β8) | 0.393 | [0.365, 0.423] |

### Model Performance (Test Set)
- **R²**: 0.84
- **MAE**: 0.32
- **MSE**: 0.16

---

## 🔍 Key Findings

- **Height** showed a strong positive association with cranial capacity — taller hominins tended to have larger brains.
- **Technology use** had the strongest positive effect, supporting the idea that tool use and cognitive development co-evolved.
- **Evolutionary time** showed a negative coefficient, confirming that more recent hominins have progressively larger brains.
- **Omnivorous diet** was negatively associated with cranial capacity — contrary to traditional assumptions — suggesting diet played a more complex role than previously thought.
- **Hard fruit diet** showed a clear positive association with brain size.
- **Carnivorous diet** showed no statistically significant effect (credible interval included 0).

---

## 🛠️ Requirements

```r
# R packages required
install.packages(c("rjags", "coda", "ggplot2", "dplyr"))
```

- R (≥ 4.0)
- JAGS (Just Another Gibbs Sampler) — [install here](https://mcmc-jags.sourceforge.io/)

---

## 🚀 How to Run

```r
# 1. Clone the repository
# 2. Open Cranial_capacity.R in RStudio
# 3. Ensure JAGS is installed on your system
# 4. Run the script to fit the Bayesian model and generate posterior distributions
# 5. Run testing.R to evaluate model performance metrics
```

---

## ⚠️ Limitations

- Correlational findings only — causality cannot be established
- Sensitive to prior distribution choices
- Computationally intensive for larger datasets
- Excludes variables such as climate, social structure, and genetic diversity

---

## 🔭 Future Work

- Incorporate climate and social complexity variables
- Apply hierarchical Bayesian models to account for phylogenetic relationships
- Extend comparisons to non-hominin primates and large-brained mammals
- Improve computational efficiency via Variational Inference

---

## 📄 Citation

If you use this work, please cite the accompanying research paper:

> *Investigating the Relationship Between Cranial Capacity and Evolutionary, Biological, and Environmental Factors in Hominins: A Bayesian Approach* (2024)

---

## 📚 References

Key references include Ash & Gallup (2007), Bailey & Geary (2009), Beaudet et al. (2019), Braun et al. (2010), and van de Schoot et al. (2021). Full reference list available in the research paper.
