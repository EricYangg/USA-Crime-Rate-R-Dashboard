# USA Crime Rate Dashboard

## Overview
This is an R Shiny dashboard for exploring violent crime trends in U.S. cities over time.

Users can:
- select a year range
- select a city
- view a line chart of violent crime rate over time
- view the cities with the highest and lowest average violent crime rate in the selected year range

## File structure
- `app.R`: main Shiny application
- `data/crime_rate_data_raw.csv`: crime dataset
- `data/uscities_raw.csv`: city coordinate dataset

## Required packages
Install the required packages in R:

```r
install.packages(c("shiny", "dplyr", "ggplot2", "readr", "bslib"))
```

## Run the app locally
From R or RStudio, run: 
```r
shiny::runApp()
```

## Development
This app is intented to be deploed on Posit Connect Cloud
