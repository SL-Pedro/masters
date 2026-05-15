# GDP Forecasting Project

This repository contains the R code and related materials used for a master’s project on GDP forecasting.

## Project Overview

The objective of this project is to compare the predictive performance of traditional linear models and data-driven machine learning models in GDP forecasting.

The study also investigates whether patent-related indicators can improve GDP forecasts and to what extent they should be considered useful forecasting variables.

## Research Questions

This study is driven by two main research questions:

1. **How do linear models compare with data-driven models in predictive performance?**

2. **To what extent can patent-related indicators be used to forecast GDP?**

## Data Sources

The data used in this project comes from:

- Eurostat
- OECD / OCDE

These sources were used to collect regional, economic, and patent-related indicators relevant to GDP forecasting.

## NUTS Version Conversion

Part of the R code was used to convert regional data from **NUTS 2013** to **NUTS 2021**.

This conversion was necessary to harmonize regional classifications across datasets and ensure consistency across different data sources and time periods.

## Methodology

The project compares the forecasting performance of:

- Autoregressive models
- Linear regression models
- Data-driven machine learning models

Patent-related indicators were included in some model specifications to test whether they improved GDP forecasting accuracy.

## Main Findings

The main findings of the project were:

- Linear models, including autoregressive models and linear regression models, showed better predictive performance than the data-driven machine learning models used in this study.
- Patent-related indicators enhanced prediction in some settings.
- However, patents did not replace traditional macroeconomic fundamentals as the main determinants of forecast accuracy.
- Overall, patents should be interpreted as supplementary forecasting variables rather than primary predictors of GDP.

## Repository Contents

This repository may include:

- R scripts for data preparation and analysis
- Code for converting NUTS 2013 regions to NUTS 2021
- GDP forecasting models
- Model accuracy comparisons
- Documentation explaining the data and methodology

## Notes on Data Availability

The datasets are not necessarily included in this repository.

Users should obtain the original data from Eurostat and OECD / OCDE, respecting the access rules and usage conditions of each data provider.

## Pedro Luís

Created as part of a master’s project.
