library(shiny)
library(ggplot2)
library(dplyr)
library(rsconnect)


library(shiny)

# Define UI for application that draws a histogram
ui = shinyUI(fluidPage(
    
    # Application title
    titlePanel("Price predictor for Diamonds"),
    
    # Sidebar with options selectors
    sidebarLayout(
        sidebarPanel(
            helpText("This application is a predictor for the price of a diamond based on its characteristics."),
            h3(helpText("Select:")),
            numericInput("car", label = h4("Carats"), step = 0.01, value = 1.5),
            selectInput("cut", label = h4("Cut"),
                        choices = list("Unknown" = "*", "Fair" = "Fair", "Good" = "^Good",
                                       "Very Good" = "Very Good", "Premium" = "Premium",
                                       "Ideal" = "Ideal")),
            selectInput("col", label = h4("Color"),
                        choices = list("Unknown" = "*", "D" = "D", "E" = "E",
                                       "F" = "F", "G" ="G",
                                       "H" = "H", "I" = "I",
                                       "J" = "J")),
            selectInput("clar", label = h4("Clarity"),
                        choices = list("Unknown" = "*", "I1" = "I1", "SI2" = "SI2",
                                       "SI1" = "SI1", "VS2" = "VS2", "VS1" = "VS1",
                                       "VVS2" = "VVS2", "VVS1" = "VVS1", "IF" = "IF" ))
        ),
        
        # Show a plot with diamonds and regression line
        mainPanel(
            plotOutput("distPlot"),
            h4("Predicted value of this diamond is:"),
            h3(textOutput("result"))
        )
    )
))


# Select columns to be used in the analysis
diam <- diamonds[,c(1:4,7)]
# Define server logic required to draw a plot
server = shinyServer(function(input, output) {
    output$distPlot <- renderPlot({
        # Select diamonds depending of user input
        diam <- filter(diamonds, grepl(input$cut, cut), grepl(input$col, color), grepl(input$clar, clarity))
        # build linear regression model
        fit <- lm( price~carat, diam)
        # predicts the price
        pred <- predict(fit, newdata = data.frame(carat = input$car,
                                                  cut = input$cut,
                                                  color = input$col,
                                                  clarity = input$clar))
        # Draw the plot using ggplot2
        plot <- ggplot(data=diam, aes(x=carat, y = price))+
            geom_point(aes(color = cut), alpha = 0.3)+
            geom_smooth(method = "lm")+
            geom_vline(xintercept = input$car, color = "red")+
            geom_hline(yintercept = pred, color = "green")
        plot
    })
    output$result <- renderText({
        # Renders the text for the prediction below the graph
        diam <- filter(diamonds, grepl(input$cut, cut), grepl(input$col, color), grepl(input$clar, clarity))
        fit <- lm( price~carat, diam)
        pred <- predict(fit, newdata = data.frame(carat = input$car,
                                                  cut = input$cut,
                                                  color = input$col,
                                                  clarity = input$clar))
        res <- paste(round(pred, digits = 1.5),"$" )
        res
    })
    
})


# Run the application 
shinyApp(ui = ui, server = server)
