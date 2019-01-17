.libPaths("/srv/shiny-server/violinplots/libs")
gitversion <- function(){ 
  git<-read.csv("/srv/shiny-server/.git/modules/violinplots/refs/heads/master", header=FALSE)
  git<-git$V1
  git<-toString(git[1])
  git<-substr(git, 1, 7)
  return(git)
}
library(shiny)
library(xlsx)
library(futile.logger)
library(tidyverse)
library(Hmisc)

futile.logger::flog.threshold(futile.logger::ERROR, name = "violinplotsLogger")

# Define server logic required to draw a dendogram
shinyServer(function(input, output, session) {
  
  # reformat input data
  plot.data <- reactive({
    inFile <- input$file1
    filetype <- input$filetype
    req(inFile)
    
    filetype_map <- c("xlsx" = 'xlsx',  'tsv' = '\t', 'csv' = ',', 'txt'=" ")
    if(filetype == 'auto'){
      file_extension =  unlist(strsplit(inFile$datapath, '[.]'))[length(unlist(strsplit(inFile$datapath, '[.]')))]
      if(file_extension %in% names(filetype_map)){
        filetype <- filetype_map[file_extension]
        names(filetype) <- NULL
        
      } else {
        print(paste("wrong file format", file_extension))
        return(NULL)
      }
    }
    
    if(filetype == 'xlsx'){
      D <- read.xlsx(inFile$datapath, sheetIndex = 1, header = input$header)
    } else {
      D <- read.csv(inFile$datapath, header = input$header, sep = filetype)
    }
    
    vars <- names(D)
    if (input$x == ""){
      updateSelectInput(session, "x","Select x-axis column", 
                        choices = c("--select--","row.names", vars), 
                        selected = "--select--")
    }
    if (input$y == ""){
      updateSelectInput(session, "y","Select y-xais column", 
                        choices = c("--select--","row.names", vars), 
                        selected = "--select--")
    }
    if (input$groups == ""){
      updateSelectInput(session, "groups","Select groups column", 
                        choices = c("--select--","row.names", vars), 
                        selected = "--select--")
    }
    req(input$x != "--select--", input$x != "", 
        input$y != "--select--", input$y != "")
    
    D[D == ''] <- NA
    D <- na.omit(D)
    
    
    D[, 'x']<-as.factor(D[,  input$x])
    D[, 'y']<-D[,  input$y]
    if ( input$groups != "--select--" ){
      D[, 'groups']<-D[,  input$groups]
      
    }

    return(D)
  })
  
  output$violinplot <- renderPlot({
    data<-plot.data()
    
    if ( input$groups == "--select--" ){
      
      p <- ggplot(data, aes(x=x, y=y)) + theme_classic() 
      p <- p + geom_violin(trim=input$trim, fill="gray")
    
      # mean and std as line
      if (isTRUE(input$meanstd)){
        p <- p + stat_summary(fun.data=mean_sdl, mult=1, 
                              geom="pointrange", color="red", position=position_dodge(0))
      }
      
      # add box
      if (isTRUE(input$box)){
        p <- p + geom_boxplot(width=0.1, position=position_dodge(0))
      }
      
      # add dots
      if (isTRUE(input$dots)){
        p <- p + geom_dotplot(binaxis='y', stackdir='center',
                              position=position_dodge(0),  dotsize=input$dotsize)
      }
      
      # median
      if (isTRUE(input$median)){
        p <- p + stat_summary(fun.y=median, geom="point", position=position_dodge(0), size=input$dotsize, color="red")
      }
      
      
    } else {

      p <- ggplot(data, aes(x=x, y=y, fill=groups)) + theme_classic() 
      p <- p + geom_violin(trim=input$trim)
      
      # mean and std as line
      if (isTRUE(input$meanstd)){
        p <- p + stat_summary(fun.data=mean_sdl, mult=1, 
                              geom="pointrange", color="red", position=position_dodge(input$dodge))
      }
      
      # add box
      if (isTRUE(input$box)){
        p <- p + geom_boxplot(width=0.1, position=position_dodge(input$dodge))
      }
      
      # add dots
      if (isTRUE(input$dots)){
        p <- p + geom_dotplot(binaxis='y', stackdir='center',
                              position=position_dodge(input$dodge),  dotsize=input$dotsize)
      }
      
      # median
      if (isTRUE(input$median)){
        p <- p + stat_summary(fun.y=median, geom="point", position=position_dodge(input$dodge), size=input$dotsize, color="red")
      }
      
    }
    p <- p + ggtitle(input$title) + xlab(input$xlabel) + ylab(input$ylabel) + 
      theme(plot.title = element_text(hjust = 0.5, size = input$fontsize.title),
            axis.text = element_text(colour="black", size = input$fontsize.axis),
            axis.title = element_text(colour="black", size = input$fontsize.axis),
            legend.text = element_text(colour="black", size = input$fontsize.legend),
            legend.title = element_text(colour="black", size = input$fontsize.legend) )
    p
  })
  
  
  
  # to download plot
  output$downloadPlot <- downloadHandler(
    
    # specify file name
    filename = function(){
      paste0(input$outfile,".",gitversion(),'.pdf')
    },
    content = function(filename){
      
      # plot
      data<-plot.data()
      
      if ( input$groups == "--select--" ){
        
        p <- ggplot(data, aes(x=x, y=y)) + theme_classic() 
        p <- p + geom_violin(trim=input$trim, fill="gray")
        
        # mean and std as line
        if (isTRUE(input$meanstd)){
          p <- p + stat_summary(fun.data=mean_sdl, mult=1, 
                                geom="pointrange", color="red", position=position_dodge(0))
        }
        
        # add box
        if (isTRUE(input$box)){
          p <- p + geom_boxplot(width=0.1, position=position_dodge(0))
        }
        
        # add dots
        if (isTRUE(input$dots)){
          p <- p + geom_dotplot(binaxis='y', stackdir='center',
                                position=position_dodge(0),  dotsize=input$dotsize)
        }
        
        # median
        if (isTRUE(input$median)){
          p <- p + stat_summary(fun.y=median, geom="point", position=position_dodge(0), size=input$dotsize, color="red")
        }
        
        
      } else {
        
        p <- ggplot(data, aes(x=x, y=y, fill=groups)) + theme_classic() 
        p <- p + geom_violin(trim=input$trim)
        
        # mean and std as line
        if (isTRUE(input$meanstd)){
          p <- p + stat_summary(fun.data=mean_sdl, mult=1, 
                                geom="pointrange", color="red", position=position_dodge(input$dodge))
        }
        
        # add box
        if (isTRUE(input$box)){
          p <- p + geom_boxplot(width=0.1, position=position_dodge(input$dodge))
        }
        
        # add dots
        if (isTRUE(input$dots)){
          p <- p + geom_dotplot(binaxis='y', stackdir='center',
                                position=position_dodge(input$dodge),  dotsize=input$dotsize)
        }
        
        # median
        if (isTRUE(input$median)){
          p <- p + stat_summary(fun.y=median, geom="point", position=position_dodge(input$dodge), size=input$dotsize, color="red")
        }
        
      }
      p <- p + ggtitle(input$title) + xlab(input$xlabel) + ylab(input$ylabel) + 
        theme(plot.title = element_text(hjust = 0.5, size = input$fontsize.title),
              axis.text = element_text(colour="black", size = input$fontsize.axis),
              axis.title = element_text(colour="black", size = input$fontsize.axis),
              legend.text = element_text(colour="black", size = input$fontsize.legend),
              legend.title = element_text(colour="black", size = input$fontsize.legend) )
      p
      # plot
      ggsave(filename)
      # close device
      #dev.off()
    }
  )
  
  output$appversion <- renderText ({ 
    paste0('App version: <b>',gitversion(),'</b>')
  }
  )
})

