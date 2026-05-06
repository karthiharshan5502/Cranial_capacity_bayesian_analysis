# Load necessary libraries
library(rjags)
library(coda)
library(lattice)  # Load lattice for densityplot

# Assuming your dataset is already loaded and named 'evolution_data'
data <- cranial_capacity1

# Convert categorical variables to factors (if not already done)
data$Diet <- as.factor(data$Diet)
data$Tecno <- as.factor(data$Tecno)

# Convert dependent variable to numeric if necessary (not needed if already numeric)
data$Cranial_Capacity <- as.numeric(data$Cranial_Capacity)

# Create the design matrix X including intercept and dummy variables
X <- model.matrix(~ Time + Height + Tecno + Diet, data = data)

# Response variable
Y <- data$Cranial_Capacity

# Define the Bayesian regression model
model_cranial_capacity_string <- "
  model {
    for (i in 1:N) {
      Cranial_Capacity[i] ~ dnorm(mu[i], tau)
      mu[i] <- beta0 + beta1 * Time[i] + beta2 * Height[i] +
               beta3 * Tecno2[i] + beta4 * Tecno3[i] +
               beta5 * Diet2[i] + beta6 * Diet3[i] + beta7 * Diet4[i] + beta8 * Diet5[i]
    }

    # Priors
    beta0 ~ dnorm(0, 0.001)
    beta1 ~ dnorm(0, 0.001)
    beta2 ~ dnorm(0, 0.001)
    beta3 ~ dnorm(0, 0.001)
    beta4 ~ dnorm(0, 0.001)
    beta5 ~ dnorm(0, 0.001)
    beta6 ~ dnorm(0, 0.001)
    beta7 ~ dnorm(0, 0.001)
    beta8 ~ dnorm(0, 0.001)

    tau <- 1 / (sigma^2)
    sigma ~ dunif(0, 100)
  }
"

# Convert categorical variables to numeric factors for the model
data_jags <- list(
  Time = data$Time,
  Height = data$Height,
  Tecno2 = as.numeric(data$Tecno == 'yes'),
  Tecno3 = as.numeric(data$Tecno == 'likely'),
  Diet2 = as.numeric(data$Diet == 'soft fruits'),
  Diet3 = as.numeric(data$Diet == 'omnivore'),
  Diet4 = as.numeric(data$Diet == 'carnivorous'),
  Diet5 = as.numeric(data$Diet == 'hard fruits'),
  Cranial_Capacity = data$Cranial_Capacity,
  N = nrow(data)
)

# Initialize the JAGS model for Cranial Capacity
model_cranial_capacity <- jags.model(
  textConnection(model_cranial_capacity_string), 
  data = data_jags, 
  n.chains = 3, 
  n.adapt = 2000
)

# Update (burn-in)
update(model_cranial_capacity, 2000)

# Sample from the posterior distribution with thinning
samples_cranial_capacity <- coda.samples(
  model_cranial_capacity, 
  variable.names = c("beta0", "beta1", "beta2", "beta3", "beta4", "beta5", "beta6", "beta7", "beta8", "sigma"), 
  n.iter = 10000, 
  thin = 10
)

# Summary of the posterior samples
summary(samples_cranial_capacity)

# Calculate the 95% credible intervals for each parameter
credible_intervals <- HPDinterval(samples_cranial_capacity, prob = 0.95)

# Display the credible intervals
print(credible_intervals)


# Trace plots for convergence diagnostics
plot(samples_cranial_capacity)

# Density plots for posterior distributions using lattice
densityplot(samples_cranial_capacity)

# Auto-correlation plots for MCMC chains using coda
autocorr.plot(samples_cranial_capacity)

# 95% Credible Intervals for the Cranial Capacity Model
HPDinterval(samples_cranial_capacity)

# Calculate Effective Sample Size for Cranial Capacity model
ess_cranial_capacity <- effectiveSize(samples_cranial_capacity)
print(ess_cranial_capacity)

# Predicted values for the Cranial Capacity model
predicted_cranial_capacity <- apply(as.matrix(samples_cranial_capacity), 1, function(x) 1 / (1 + exp(-(x["beta0"] + x["beta1"] * data$Time + x["beta2"] * data$Height +
                                                                                                         x["beta3"] * data_jags$Tecno2 + x["beta4"] * data_jags$Tecno3 + 
                                                                                                         x["beta5"] * data_jags$Diet2 + x["beta6"] * data_jags$Diet3 + 
                                                                                                         x["beta7"] * data_jags$Diet4 + x["beta8"] * data_jags$Diet5))))

# Residuals for the Cranial Capacity model
residuals_cranial_capacity <- data$Cranial_Capacity - colMeans(predicted_cranial_capacity)

# Plot Residuals vs Fitted values
plot(colMeans(predicted_cranial_capacity), residuals_cranial_capacity, main = "Residuals vs Fitted (Cranial Capacity Model)", xlab = "Fitted values", ylab = "Residuals")
abline(h = 0, col = "red")


# Convert MCMC samples to a matrix for easier manipulation
samples_matrix <- as.matrix(samples_cranial_capacity)

# Number of posterior samples and observations
n_samples <- nrow(samples_matrix)
n_obs <- data_jags$N

# Initialize a matrix to store predicted cranial capacities
predicted_cranial_capacity <- matrix(NA, nrow = n_obs, ncol = n_samples)

# Loop through each observation and compute predicted values for each posterior sample
for (i in 1:n_obs) {
  predicted_cranial_capacity[i, ] <- samples_matrix[, "beta0"] +
    samples_matrix[, "beta1"] * data_jags$Time[i] +
    samples_matrix[, "beta2"] * data_jags$Height[i] +
    samples_matrix[, "beta3"] * data_jags$Tecno_no[i] +
    samples_matrix[, "beta4"] * data_jags$Tecno_yes[i] +
    samples_matrix[, "beta5"] * data_jags$Diet_dry_fruits[i] +
    samples_matrix[, "beta6"] * data_jags$Diet_hard_fruits[i] +
    samples_matrix[, "beta7"] * data_jags$Diet_omnivore[i] +
    samples_matrix[, "beta8"] * data_jags$Diet_soft_fruits[i]
}

# Calculate the mean predicted cranial capacity for each observation across all samples
mean_predicted_cranial_capacity <- rowMeans(predicted_cranial_capacity)

# Ensure that residuals are calculated correctly
residuals_cranial_capacity <- data$Cranial_Capacity - mean_predicted_cranial_capacity

# Check lengths to ensure they match
length(mean_predicted_cranial_capacity)  # Should match nrow(data)
length(residuals_cranial_capacity)  # Should match nrow(data)

# Plot Residuals vs. Fitted values
plot(mean_predicted_cranial_capacity, residuals_cranial_capacity,
     main = "Residuals vs Fitted (Cranial Capacity Model)",
     xlab = "Fitted values", ylab = "Residuals")
abline(h = 0, col = "red")
