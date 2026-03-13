library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(bslib)
library(htmltools)

# Load and clean data
crime <- read_csv("data/crime_rate_data_raw.csv", show_col_types = FALSE) |>
  select(-any_of(c("source", "url"))) |>
  rename(city = department_name) |>
  mutate(
    city = sub(",.*", "", city),
    state_id = substr(ORI, 1, 2)
  )

cities <- read_csv("data/uscities_raw.csv", show_col_types = FALSE) |>
  filter(state_name != "Puerto Rico") |>
  select(city, state_id, lat, lng)

crime_merged <- crime |>
  inner_join(cities, by = c("city", "state_id")) |>
  mutate(city_label = paste0(city, ", ", state_id)) |>
  distinct()

city_choices <- sort(unique(crime_merged$city_label))

default_cities <- c("San Francisco, CA", "Chicago, IL", "Seattle, WA")
default_cities <- default_cities[default_cities %in% city_choices]

if (length(default_cities) == 0) {
  default_cities <- city_choices[1:min(3, length(city_choices))]
}

year_min <- min(crime_merged$year, na.rm = TRUE)
year_max <- max(crime_merged$year, na.rm = TRUE)
default_year_min <- max(year_max - 19, year_min)

# UI
ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "flatly"),

  titlePanel("USA Crime Rate Dashboard"),

  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "year_range",
        "Select year range:",
        min = year_min,
        max = year_max,
        value = c(default_year_min, year_max),
        sep = ""
      ),
      selectizeInput(
        "city_label",
        "Select city/cities:",
        choices = city_choices,
        selected = default_cities,
        multiple = TRUE,
        options = list(
          placeholder = "Choose one or more cities",
          plugins = list("remove_button")
        )
      )
    ),

    mainPanel(
      fluidRow(
        column(
          width = 6,
          uiOutput("highest_kpi")
        ),
        column(
          width = 6,
          uiOutput("lowest_kpi")
        )
      ),

      br(),

      card(
        card_header("Violent Crime Trend for Selected Cities"),
        card_body(
          plotOutput("trend_plot", height = "450px")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {

  filtered_years <- reactive({
    crime_merged |>
      filter(
        year >= input$year_range[1],
        year <= input$year_range[2]
      )
  })

  selected_city_data <- reactive({
    req(input$city_label)
    req(length(input$city_label) > 0)

    filtered_years() |>
      filter(city_label %in% input$city_label) |>
      arrange(city_label, year)
  })

  city_summary <- reactive({
    req(input$city_label)

    selected_city_data() |>
      group_by(city_label) |>
      summarise(
        avg_violent_rate = mean(violent_per_100k, na.rm = TRUE),
        .groups = "drop"
      ) |>
      filter(!is.na(avg_violent_rate))
  })

  highest_city_row <- reactive({
    city_summary() |>
      arrange(desc(avg_violent_rate)) |>
      slice(1)
  })

  lowest_city_row <- reactive({
    city_summary() |>
      arrange(avg_violent_rate) |>
      slice(1)
  })

  year_range_label <- reactive({
    paste0(input$year_range[1], "–", input$year_range[2])
  })

  output$highest_kpi <- renderUI({
    req(nrow(highest_city_row()) > 0)

    value_box(
      title = "Highest Avg Violent Crime Rate (Selected Cities)",
      value = highest_city_row()$city_label,
      showcase = tags$span(
        style = "font-size: 2rem;",
        HTML("&#9650;")
      ),
      theme = value_box_theme(bg = "#f8d7da", fg = "#842029"),
      p(
        paste0(
          "Average violent crime rate: ",
          round(highest_city_row()$avg_violent_rate, 1),
          " per 100,000 people"
        ),
        style = "margin-bottom: 0.35rem;"
      ),
      p(
        paste0("Based on selected cities, ", year_range_label()),
        style = "margin-bottom: 0; font-size: 0.95rem;"
      )
    )
  })

  output$lowest_kpi <- renderUI({
    req(nrow(lowest_city_row()) > 0)

    value_box(
      title = "Lowest Avg Violent Crime Rate (Selected Cities)",
      value = lowest_city_row()$city_label,
      showcase = tags$span(
        style = "font-size: 2rem;",
        HTML("&#9660;")
      ),
      theme = value_box_theme(bg = "#d1e7dd", fg = "#0f5132"),
      p(
        paste0(
          "Average violent crime rate: ",
          round(lowest_city_row()$avg_violent_rate, 1),
          " per 100,000 people"
        ),
        style = "margin-bottom: 0.35rem;"
      ),
      p(
        paste0("Based on selected cities, ", year_range_label()),
        style = "margin-bottom: 0; font-size: 0.95rem;"
      )
    )
  })

  output$trend_plot <- renderPlot({
    req(input$city_label)

    selected_city_data() |>
      ggplot(aes(x = year, y = violent_per_100k, color = city_label)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      labs(
        title = "Violent Crime Rate for Selected Cities",
        x = "Year",
        y = "Violent crime rate per 100,000",
        color = "City"
      ) +
      theme_minimal(base_size = 14)
  })
}

shinyApp(ui = ui, server = server)