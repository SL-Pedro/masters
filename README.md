# GDP Forecasting Project

This repository contains the R and Python code used for a master's project on regional GDP forecasting.

## Project Overview

The objective of this project is to compare the predictive performance of traditional linear models and data-driven machine learning models in forecasting the growth of GDP per capita across European NUTS 2 regions.

The study also investigates whether patent-related indicators can improve GDP forecasts, to what extent they should be considered useful forecasting variables, and whether that value changes across forecasting horizons.

## Research Questions

This study is driven by two main questions:

1. How do linear models compare with data-driven models in predictive performance?
2. To what extent can patent-related indicators be used to forecast GDP?

## Data Sources

The data used in this project comes from:

* Eurostat
* OECD REGPAT database (EPO patent applications, fractional counting, NUTS 2 level)
* ARDECO - SOVGDP

These sources were used to collect regional, economic, and patent-related indicators relevant to GDP forecasting.

## NUTS Version Conversion

Part of the R code (`NUTS5_1_corrected.R`) harmonizes regional classifications across multiple NUTS versions into NUTS 2021, ensuring consistency across datasets and time periods. The classification version is resolved per country-year, producing a patent-augmented panel covering 25 EU countries / 207 NUTS 2 regions (209 regions in the full replication panel, before merging with patent data). The script saves its output as `EPO_NUTS2_2021_features_corrected.csv`.

## Methodology

The project builds non-overlapping panels at two forecasting horizons — 1 year and 2 years — where the dependent variable is the cumulative log-growth of GDP per capita from anchor year T to T+Δ, and regressors are measured at T. The panel covers 2000–2019 (anchor years 2003–2018). Models are trained on anchor years up to 2013 and tested on later anchor years.

For each horizon, it compares:

* Autoregressive (naïve persistence) baseline
* Linear regression (including a fixed-effects / within-transformation specification)
* Random Forest
* Gradient Boosting

Patent indicators are tested in two forms — raw patent count and log-transformed lagged patent count — and added to each model to measure predictive gains. Differences between models, and between base and patent-augmented specifications, are assessed with Diebold-Mariano tests. SHAP analysis is used to inspect feature importance across the Linear Regression, Random Forest, and Gradient Boosting specifications, and regional forecast maps are produced for a future anchor year.

## Main Findings

* Linear regression with fixed effects had the lowest forecast error at both horizons (e.g., at Δ=2, RMSE 2.67 vs. 3.27 for Random Forest and 3.25 for Gradient Boosting), and the differences are significant by Diebold-Mariano tests.
* Patent indicators improved Random Forest at both horizons (largest gain at Δ=1) and Gradient Boosting at Δ=2; the Gradient Boosting gain at Δ=1 is negligible. The gains for Random Forest (both horizons) and Gradient Boosting (Δ=2) are statistically significant.
* Patent indicators gave little to no improvement for Linear Regression at either horizon.
* Patents did not replace traditional macroeconomic fundamentals as the main determinants of forecast accuracy — they act as supplementary variables, mainly useful to the nonlinear models.

## Repository Contents

This repository includes:

* `README.md`
* `NUTS5_1_corrected.R` — NUTS version harmonization script (to NUTS 2021)
* `Patents1.4_EN.ipynb` — panel construction, 1-year and 2-year horizon models, patent indicator tests, SHAP analysis, Diebold-Mariano tests, and regional forecast maps

## Notes on Data Availability

The datasets are not included in this repository. Users should obtain the original data from Eurostat, OECD (REGPAT), and ARDECO, respecting the access rules and usage conditions of each data provider.

## Author

Pedro Luís

Created as part of a master's project.
