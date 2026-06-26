# MNTS-ARMA-GARCH-Portfolio-Optimization

An interactive R Shiny application for portfolio optimization and tail-risk management using ARMA-GARCH Multivariate Normal Tempered Stable (MNTS) models.

Developed for AMS 487 at Stony Brook University under the supervision of Prof. Aaron Y.S. Kim.

## Tech Stack and Dependencies
* Language: R
* Core Libraries: shiny, temStaR (v0.90), quantmod, nloptr

## key Features
* Fits empirical historical stock data using heavy-tailed MNTS distributions.
* Minimizes portfolio tail-risk and generates dynamic risk metrics.
* Computes and visualizes Marginal Contribution to CVaR (MCT-CVaR) via a Shiny dashboard.

## File Structure
* app.R: Main R Shiny application interface and server logic.
* .gitignore: Configured to exclude internal simulation scripts (proc_*.R) and large datasets.
