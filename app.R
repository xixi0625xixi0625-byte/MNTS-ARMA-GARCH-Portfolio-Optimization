library(shiny)
library(nloptr)
library(pracma)
library(functional)
library(Matrix)
library(spatstat)
library(quantmod)
library(temStaR)
library(doParallel)

# [NOTE] Local working directory - commented out for GitHub portability
# setwd("C:/Users/Lenovo/Desktop/r")

if (file.exists("readStockData.R")) {
  source("readStockData.R")
}

# source("readHistoryStockDataFromYahoo.R")

source("readStockData.R")
source("temstarDist.R")
source("distNTS.R")
source("distMultiNTS.R")
source("CVaRMultiNTS.R")

ui <- fluidPage(
  titlePanel("Portfolio Risk Analysis via NTS Model"),
  sidebarLayout(
    sidebarPanel(
      dateInput("curdate", "Analysis Baseline Date:", value = "2021-12-31"),
      actionButton("go", "Run Calculation"),
      hr(),
      helpText("Note: Computing MCT-CVaR for 3 assets takes approximately 10-20 seconds.")
    ),
    mainPanel(
      h4("Model Parameter Results:"),
      verbatimTextOutput("Result"),
      h4("Marginal Contribution to Risk (MCT-CVaR):"),
      plotOutput("barPlot1")
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$go, {
    
    yTickers <- c("GOOG", "AAPL", "DIS")
    numofelements <- length(yTickers)
    enddate <- input$curdate
    screensize <- 1000
    begindate <- as.Date(input$curdate) - screensize
    
    withProgress(message = 'Fetching data and fitting model...', value = 0, {
      
      dailyret_list <- list()
      for (i in 1:numofelements){
        tpr <- getDailyReturn(yTickers[i], begindate, enddate)
        dailyret_list[[i]] <- tpr$ret
      }
      
      min_len <- min(sapply(dailyret_list, length))
      dailyret <- matrix(nrow = min_len, ncol = numofelements)
      for(i in 1:numofelements) dailyret[,i] <- tail(dailyret_list[[i]], min_len)
      
      incProgress(0.3, detail = "Fitting Multivariate NTS Model")
      options(warn=-1)
      st <- fitmnts(returndata = dailyret, n = numofelements)
      options(warn = 0)
      
      incProgress(0.4, detail = "Calculating MCT-CVaR Metrics")
      eta <- 0.01
      w <- rep(1/numofelements, numofelements)
      
      mctCVaRArray <- array(dim = numofelements, dimnames = list(yTickers))
      for(x in 1:numofelements){
        
        mctCVaRArray[x] <- mctCVaR_MNTS(x, eta, w, st)
      }
      
      output$Result <- renderPrint({
        cat("stdNTS Parameters:\n")
        cat("alpha =", st$alpha, " | theta =", st$theta, " | beta =", st$beta, "\n\n")
        cat("MCT-CVaR Results:\n")
        print(mctCVaRArray)
      })
      
      output$barPlot1 <- renderPlot({
        barplot(mctCVaRArray, main = "Marginal Contribution To CVaR (99%)",
                col = "steelblue", border = "white", las = 2)
      })
    })
  })
}

shinyApp(ui = ui, server = server)
