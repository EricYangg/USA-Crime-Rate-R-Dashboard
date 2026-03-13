# USA Crime Rate Dashboard

This is an interactive Shiny dashboard exploring violent crime trends across selected US cities.

Posit Connect Cloud Link: <https://019ce607-62e0-0ded-fafe-2966fb8f8d56.share.connect.posit.cloud/> 

## Features
- Filter by year range
- Select multiple cities
- View violent crime trends
- Compare highest and lowest average violent crime rates among selected cities

## Run locally

Install packages:

```r
install.packages(c(
  "shiny",
  "dplyr",
  "ggplot2",
  "readr",
  "bslib",
  "htmltools",
  "renv"
))
```

Run the app:
```r
shiny::runApp()
```

## Deployment

The app is deployed on Posit Connect Cloud.
