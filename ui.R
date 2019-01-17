.libPaths("/srv/shiny-server/violinsplots/libs")
library(shiny)
# Define UI for application that draws a histogram

shinyUI( fluidPage(
  titlePanel("Violin plots"),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Input data",
                  fileInput("file1", "Choose File",
                            accept = c("text/csv",
                                       "text/comma-separated-values,text/plain",
                                       ".csv",
                                       ".tsv",
                                       ".xlsx")
                  ),
                  radioButtons("filetype", 'Please select the input file type', choices = c('auto' = 'auto', 
                                                                                            "excel" = 'xlsx',  
                                                                                            'tab-separated' = '\t', 
                                                                                            'comma-seperated' = ',', 
                                                                                            'semicolon-separated' = ';'), inline = TRUE),
                  checkboxInput("header", "Header", TRUE),
                  helpText(a(href = "https://datashare.mpcdf.mpg.de/s/aKFeWHTy0ILClpk/download", "Example input")),
                  hr(),
                  selectInput("x", "Select x-axis column", choices = NULL,selected=NULL),
                  selectInput("y", "Select y-axis column", choices = NULL,selected=NULL),
                  selectInput("groups", "Select groups column", choices = NULL,selected=NULL),
                  checkboxInput("trim", "Trim", FALSE),
                  checkboxInput("median", "Median", FALSE),
                  checkboxInput("meanstd", "Mean and standard deviation", FALSE),
                  checkboxInput("box", "Median and quartile", FALSE),
                  checkboxInput("dots", "Dots", FALSE),
                 hr(),
                  textInput("outfile", "Output file name", value="violinplot")
                 ),
      tabPanel("Plot settings",
              sliderInput('dodge', 'Dodge (when using groups)', min = 0, max = 5, value = 0.9, step = 0.1),     #checkboxInput("dodge", "Dodge", FALSE),
              sliderInput('dotsize', 'Dots size', min = 0, max = 2, value = 0.5, step = 0.05),     #checkboxInput("dodge", "Dodge", FALSE),
              textInput("title", "Plot title", value="Violin plot"),
              textInput("xlabel", "X-axis label", "x-axis"),
              textInput("ylabel", "Y-axis label", "y-axis"),
              sliderInput("fontsize.title", "Title font size", min = 8, max = 50, value = 32, step = 1),
              sliderInput("fontsize.axis", "Axes font size", min = 8, max = 32, value = 18, step = 1),
              sliderInput("fontsize.legend", "Legend font size", min = 8, max = 32, value = 14, step = 1),
              numericInput("plotwidth", "Plot width", 600),
              numericInput("plotheight", "Plot height", 400)
      )
    )),
    mainPanel(
      plotOutput("violinplot", height = 'auto', width = 'auto'),
      downloadButton('downloadPlot', 'Download Plot'),
      br(), br(),
      p("This App uses the gplot2 package. For more information read the respective documentation in",
        a("tidyverse.org", href = "https://ggplot2.tidyverse.org"),
        "."),
      p("Please keep the version tag on all downloaded files."),
      htmlOutput('appversion')
    )
  )
))
