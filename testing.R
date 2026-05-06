# Load necessary libraries
library(rjags)
library(coda)
library(lattice)  # For density plots
library(boot)     # For R-squared calculation


data = cranial_capacity1
# Set seed for reproducibility
set.seed(123)

# Split the data into training (70%) and testing (30%) sets
n <- nrow(data)
train_indices <- sample(1:n, size = 0.7 * n)
train_data <- data[train_indices, ]
test_data <- data[-train_indices, ]

# Prepare data lists for JAGS (training set only)
train_data_jags <- list(
  Time = train_data$Time,
  Height = train_data$Height,
  Tecno2 = as.numeric(train_data$Tecno == 'yes'),
  Tecno3 = as.numeric(train_data$Tecno == 'likely'),
  Diet2 = as.numeric(train_data$Diet == 'soft fruits'),
  Diet3 = as.numeric(train_data$Diet == 'omnivore'),
  Diet4 = as.numeric(train_data$Diet == 'carnivorous'),
  Diet5 = as.numeric(train_data$Diet == 'hard fruits'),
  Cranial_Capacity = train_data$Cranial_Capacity,
  N = nrow(train_data)
)

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

# Initialize the JAGS model for Cranial Capacity using the training data
model_cranial_capacity <- jags.model(
  textConnection(model_cranial_capacity_string), 
  data = train_data_jags, 
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

# Convert MCMC samples to a matrix for easier manipulation
samples_matrix <- as.matrix(samples_cranial_capacity)

# Make predictions on the testing set
n_samples <- nrow(samples_matrix)
n_obs_test <- nrow(test_data)

predicted_cranial_capacity_test <- matrix(NA, nrow = n_obs_test, ncol = n_samples)

for (i in 1:n_obs_test) {
  predicted_cranial_capacity_test[i, ] <- samples_matrix[, "beta0"] +
    samples_matrix[, "beta1"] * test_data$Time[i] +
    samples_matrix[, "beta2"] * test_data$Height[i] +
    samples_matrix[, "beta3"] * as.numeric(test_data$Tecno == 'yes')[i] +
    samples_matrix[, "beta4"] * as.numeric(test_data$Tecno == 'likely')[i] +
    samples_matrix[, "beta5"] * as.numeric(test_data$Diet == 'soft fruits')[i] +
    samples_matrix[, "beta6"] * as.numeric(test_data$Diet == 'omnivore')[i] +
    samples_matrix[, "beta7"] * as.numeric(test_data$Diet == 'carnivorous')[i] +
    samples_matrix[, "beta8"] * as.numeric(test_data$Diet == 'hard fruits')[i]
}

mean_predicted_cranial_capacity_test <- rowMeans(predicted_cranial_capacity_test)

# Calculate residuals for the test set
residuals_cranial_capacity_test <- test_data$Cranial_Capacity - mean_predicted_cranial_capacity_test

# Calculate R-squared for the test set
ss_total <- sum((test_data$Cranial_Capacity - mean(test_data$Cranial_Capacity))^2)
ss_res <- sum(residuals_cranial_capacity_test^2)
r_squared <- 1 - (ss_res / ss_total)
print(paste("R-squared on Test Set:", r_squared))

# Calculate Mean Absolute Error (MAE)
mae_test <- mean(abs(residuals_cranial_capacity_test))
print(paste("Mean Absolute Error (MAE) on Test Set:", mae_test))

# Calculate Mean Squared Error (MSE)
mse_test <- mean(residuals_cranial_capacity_test^2)
print(paste("Mean Squared Error (MSE) on Test Set:", mse_test))

# Residual plot
plot(mean_predicted_cranial_capacity_test, residuals_cranial_capacity_test,
     main = "Residuals vs Fitted (Test Set, Cranial Capacity Model)",
     xlab = "Fitted values", ylab = "Residuals")
abline(h = 0, col = "red")

# QQ plot for residuals
qqnorm(residuals_cranial_capacity_test, main = "QQ Plot of Residuals")
qqline(residuals_cranial_capacity_test, col = "red")

# Calculate R-squared for each posterior sample
r_squared_samples <- numeric(n_samples)

for (j in 1:n_samples) {
  # Predicted values for the j-th sample
  predicted_test_sample <- predicted_cranial_capacity_test[, j]
  
  # Residual sum of squares for the j-th sample
  ss_res_sample <- sum((test_data$Cranial_Capacity - predicted_test_sample)^2)
  
  # Total sum of squares
  ss_total <- sum((test_data$Cranial_Capacity - mean(test_data$Cranial_Capacity))^2)
  
  # R-squared calculation for the j-th sample
  r_squared_samples[j] <- 1 - (ss_res_sample / ss_total)
}

# Plot the distribution of R-squared values
hist(r_squared_samples, breaks = 30, col = "blue", main = "R-squared Distribution", xlab = "R-squared")
dev.off()