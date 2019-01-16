.libPaths("/srv/shiny-server/violinplots/libs")

if(!require(futile.logger)){
  install.packages("futile.logger", dependencies = TRUE)
  library(futile.logger)
}

if(!require(xlsx)){
  install.packages("xlsx", dependencies = TRUE)
  library(xlsx)
}

if(!require(tidyverse)){
  install.packages("tidyverse", dependencies = TRUE)
  library(tidyverse)
}

if(!require(Hmisc)){
  install.packages("Hmisc", dependencies = TRUE)
  library(Hmisc)
}

quit(save="no")

ToothGrowth$dose <- as.factor(ToothGrowth$dose)
head(ToothGrowth)

library(ggplot2)
# Basic violin plot
p <- ggplot(ToothGrowth, aes(x=dose, y=len)) + 
  geom_violin()
p
# Rotate the violin plot
p + coord_flip()
# Set trim argument to FALSE
ggplot(ToothGrowth, aes(x=dose, y=len)) + 
  geom_violin(trim=FALSE)

# p + scale_x_discrete(limits=c("0.5", "2"))

# violin plot with mean points
p + stat_summary(fun.y=mean, geom="point", shape=23, size=2)
# violin plot with median points
p + stat_summary(fun.y=median, geom="point", size=2, color="red")
p + geom_boxplot(width=0.1)


#p + stat_summary(fun.data="mean_sdl", mult=1, 
#                 geom="crossbar", width=0.2 )
p <- ggplot(ToothGrowth, aes(x=dose, y=len)) + 
  geom_violin(trim=FALSE)
p + stat_summary(fun.data=mean_sdl, mult=1, 
                 geom="pointrange", color="red")
# violin plot with dot plot
p + geom_dotplot(binaxis='y', stackdir='center', dotsize=0.5)



#### main ####


p <- ggplot(ToothGrowth, aes(x=dose, y=len)) + theme_classic() 
p <- p + geom_violin(trim=FALSE)
p
# mean and std as line
p <- p + stat_summary(fun.data=mean_sdl, mult=1, 
                      geom="pointrange", color="red", position=position_dodge(0))
p

# add box
p <- p + geom_boxplot(width=0.1, position=position_dodge(0))
p

# add dots
p <- p + geom_dotplot(binaxis='y', stackdir='center',
                      position=position_dodge(0),  dotsize=0.5)
p

##############

p <- ggplot(ToothGrowth, aes(x=dose, y=len, fill=supp)) + theme_classic() 
p <- p + geom_violin(trim=FALSE)
p
# mean and std as line
p <- p + stat_summary(fun.data=mean_sdl, mult=1, 
                 geom="pointrange", color="red", position=position_dodge(0.9))

# add box
p <- p + geom_boxplot(width=0.1, position=position_dodge(0.9))
p

# add dots
p <- p + geom_dotplot(binaxis='y', stackdir='center',
                    position=position_dodge(0.9),  dotsize=0.5)

##############


# violin plot with dot plot
# Add dots
p + geom_dotplot(binaxis='y', stackdir='center',
                 position=position_dodge(0.9),  dotsize=0.5)
p + theme_classic()
p + geom_boxplot(width=0.1, position=position_dodge(0.9))

