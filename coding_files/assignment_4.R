library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(viridis)

# Data preparation remains the same
dataset <- read.csv("exam.csv") 
data = dataset %>%
  mutate(
    datetime = ymd_h(paste(Year, Month, Day, Time)),
    Storm_Category = as.factor(Storm_Category),
    Status = as.factor(Status)
  )


metrics <- c("Pressure", "Wind_Speed", "Rain_Level", "Diameter_of_Tropical_Storm", "Force_of_Hurricane")
summary_measures <- c("Status", "Storm_Category","Wind_Speed", "Pressure", 
                      "Diameter_of_Tropical_Storm", "Force_of_Hurricane", "Rain_Level")

ui <- navbarPage(
  title = "Storms Data Analysis",
  
  tabPanel("Plot",
           sidebarLayout(
             sidebarPanel(
               # Year range slider
               sliderInput(
                 inputId = "year_range",
                 label = "Select Year",
                 min = min(data$Year),
                 max = max(data$Year),
                 value = c(min(data$Year), max(data$Year)),
                 step = 1,
                 sep = "",
                 ticks = FALSE  # remove tickers
               ),
               
               selectInput(
                 inputId = "metric",
                 label = "Select Metric",
                 choices = metrics
               ),
               
               selectInput(
                 inputId = "storm_cat",
                 label = "Select Storm Category",
                 choices = sort(unique(data$Storm_Category[!is.na(data$Storm_Category)])),
                 multiple = TRUE
               )
             ),
             mainPanel(
               plotOutput(outputId = "time_plot")
             )
           )
  ),
  
  tabPanel("Overview",
           sidebarLayout(
             sidebarPanel(
               selectInput(
                 inputId = "summary_vars",
                 label = "Select Summary Measures",
                 choices = names(data)[names(data) %in% summary_measures],
                 multiple = TRUE
               )
             ),
             mainPanel(
               verbatimTextOutput(outputId = "summary_stats")
             )
           )
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for valid date range
  valid_years <- reactive({
    req(input$metric)
    # Filter out NA values for the selected metric
    valid_data <- data %>% 
      filter(!is.na(.data[[input$metric]]))
    
    list(
      min_year = min(valid_data$Year),
      max_year = max(valid_data$Year)
    )
  })
  
  # I want to update Year slider range when metric changes
  observeEvent(input$metric, {
    years <- valid_years()
    updateSliderInput(session, "year_range",
                      min = years$min_year,
                      max = years$max_year,
                      value = c(years$min_year, years$max_year))
  })
  
  # Filtered data based on inputs
  filtered_data <- reactive({
    req(input$storm_cat, input$metric)
    data %>%
      filter(
        Year >= input$year_range[1],
        Year <= input$year_range[2],
        Storm_Category %in% input$storm_cat | is.na(Storm_Category),
        !is.na(.data[[input$metric]])  # Filter out NA values for selected metric
      )
  })
  
  # time series plot with dynamic y-axis limits
  output$time_plot <- renderPlot({
    req(filtered_data())
    
    # calculate y-axis limits based on actual data range to avoid the plots looking funky
    y_range <- range(filtered_data()[[input$metric]], na.rm = TRUE)
    y_padding <- (y_range[2] - y_range[1]) * 0.05  # add 5% padding for cleaner look
    
    ggplot(filtered_data(),
           aes(x = datetime, y = .data[[input$metric]], color = Storm_Category)) +
      geom_point(alpha = 0.6) +
      geom_smooth(method = "loess", se = FALSE) +
      scale_color_viridis_d(option = "viridis", na.translate = FALSE) + # na.translate to false to remove NAs from label
      labs(
        title = "Storm Intensity Over Time",
        x = "Time",
        y = input$metric,
        color = "Storm Category"
      ) +
      theme_minimal() +
      coord_cartesian(
        ylim = c(y_range[1] - y_padding, y_range[2] + y_padding)
      )
  })
  
  output$summary_stats <- renderPrint({
    req(input$summary_vars)
    summary(data[, input$summary_vars, drop = FALSE])
  })
}

shinyApp(ui = ui, server = server)