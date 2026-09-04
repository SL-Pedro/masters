# GDP Forecasting Project

This repository contains the R and Python code used for a master's project on GDP forecasting.

## Project Overview

The objective of this project is to compare the predictive performance of traditional linear models and data-driven machine learning models in GDP forecasting.

The study also investigates whether patent-related indicators can improve GDP forecasts, to what extent they should be considered useful forecasting variables, and whether that value changes across forecasting horizons.

## Research Questions

This study is driven by three main questions:

1. **How do linear models compare with data-driven models in predictive performance?**
2. **To what extent can patent-related indicators be used to forecast GDP?**

## Data Sources

The data used in this project comes from:

- Eurostat
- OECD / OCDE
- ARDECO - SOVGDP
- EPO (patent counts, NUTS2 level)

These sources were used to collect regional, economic, and patent-related indicators relevant to GDP forecasting.

## NUTS Version Conversion

Part of the R code (`NUTS5_1_corrected.R`) harmonizes regional classifications across multiple NUTS versions — **2010, 2013, and 2016** — into **NUTS 2021**, ensuring consistency across datasets and time periods. The classification version is resolved **per country-year**, producing a patent-augmented panel covering **25 EU countries / 207 NUTS 2 regions** (209 regions in the full replication panel, before merging with patent data).

## Methodology

The project builds non-overlapping panels at two forecasting horizons — **1 year** and **2 years** — where the dependent variable is the cumulative log-growth of GDP per capita from anchor year T to T+Δ, and regressors are measured at T.

For each horizon, it compares:

- Autoregressive baseline
- Linear regression (including a fixed-effects / within-transformation specification)
- Random Forest
- Gradient Boosting

Patent indicators are tested in two forms — raw patent count and log-transformed lagged patent count — and added to each model to measure predictive gains. SHAP analysis is used to inspect feature importance across the Linear Regression, Random Forest, and Gradient Boosting specifications, and regional forecast maps are produced for a future anchor year.

## Main Findings

- Linear models (autoregressive and linear regression with fixed effects) had lower forecast error than Random Forest and Gradient Boosting at both horizons — e.g., at Δ=2, Linear FE RMSE was 2.67 vs. 3.27 (RF) and 3.25 (GB).
- Patent indicators improved the nonlinear models (Random Forest, Gradient Boosting) at both horizons, with the largest gain for Random Forest at the 1-year horizon.
- Patent indicators gave little to no improvement for Linear Regression at either horizon.
- Patents did not replace traditional macroeconomic fundamentals as the main determinants of forecast accuracy — they act as supplementary variables, mainly useful to the nonlinear models.

## Repository Contents

This repository includes:

- `README.md`
- `NUTS5_1_corrected.R` — NUTS 2010/2013/2016 → 2021 harmonization script
- `Patents1.4.ipynb` — panel construction, 1-year and 2-year horizon models, patent indicator tests, SHAP analysis, and regional forecast maps

## Notes on Data Availability

The datasets are not necessarily included in this repository. Users should obtain the original data from Eurostat, OECD / OCDE, and EPO, respecting the access rules and usage conditions of each data provider.

## Pedro Luís

Created as part of a master's project.
