library(ggplot2)
setwd("/home/jonas/workspace/udacity/lessons/05 - Exploratory Data Analysis")
getwd()

data(diamonds)  # load data set (comes with ggplot2)

# 1) Some key information

names(diamonds)
dim(diamonds)  # number of variables

?diamonds  # best description (markdown)
summary(diamonds)
diamonds
head(diamonds, 5)
str(diamonds)
nrow(diamonds)

# 2+3) Print a histogram

qplot(diamonds$price)
summary(diamonds$price)
install.packages('moments', dependencies = T)
library(moments)
skewness(diamonds$price)
kurtosis(diamonds$price)

# 4) How many?

nrow(diamonds[diamonds$price < 500,])
nrow(subset(diamonds, price < 250))
nrow(subset(diamonds, price >= 15000))


# 5) Limit the x-axis

qplot(diamonds$price, binwidth = 1) +
  scale_x_continuous(limits = c(0, 1500))
ggsave("diamonds_histogram.png")

# 6+7+8) Break down by "cut" type

?diamonds
qplot(x = price, data = diamonds) +
  facet_wrap(~diamonds$cut, ncol = 2, scales = "free_y")  # do not use the same scale for all plots

options(digits=10)  # set display precision
by(diamonds$price, diamonds$cut, summary)

# 9) Create new variable price per carat and break it down by cut

diamonds$price_per_carat <- diamonds$price / diamonds$carat
qplot(x = price_per_carat, data = diamonds) + 
  facet_wrap(~cut, ncol=5) + 
  scale_x_log10()


# 10) Further investigation using box-plots, numerical summaries, etc.

?diamonds

by(diamonds$price, diamonds$cut, summary)
qplot(x = cut, y = price, data = diamonds, geom = "boxplot")
ggsave("boxplot_price_by_cut.png")

by(diamonds$price, diamonds$clarity, summary)
qplot(x = clarity, y = price, data = diamonds, geom = "boxplot")
ggsave("boxplot_price_by_clarity.png")

by(diamonds$price, diamonds$color, summary)
qplot(x = color, y = price, data = diamonds, geom = "boxplot")
ggsave("boxplot_price_by_color.png")


# 11) IQR

IQR(subset(diamonds, color == "D")$price)
IQR(subset(diamonds, color == "J")$price)


# 12) 

qplot(x = color, y = price_per_carat, data = diamonds, geom = "boxplot")
ggsave("boxplot_price_per_carat_by_color.png")


# 13) Frequency polygon

qplot(x = carat, data = diamonds, geom = "freqpoly"
      #, color=color
      ) 
qplot(x = carat, data = diamonds, binwidth=0.01) 

#subset(data, )


# 13) Gapminder data

homicide <- read.csv("Homicide age adjusted indicator LIVE -05 20100919.csv", header = T, row.names = 1, check.names = F)
#homicide <- t(homicide)  # transpose table
attributes(homicide)
names(attributes(homicide)$dimnames) <- c("country", "year")  # name dimensions


head(homicide)
names(homicide)
dim(homicide)
qplot(x = year, y = data = homicide, geom = "freqpoly", color = country)


# 14+15) Packages tidyr and dplr for data munging with R.

# Dataset for demonstration purposes
install.packages("httr")
install.packages("devtools")
library("devtools")
install_github("rstudio/EDAWR")
library(EDAWR)
?storms
?cases
?tb
?pollution

# tidyr: transform data into tidy format
install.packages("tidyr")
library(tidyr)
??tidyr
?gather
cases
gather(cases, "year", "n", 2:4)


?spread
pollution
spread(pollution, "size", "amount")

# dplyr: transformations for tabular data
install.packages("dplyr")
library(dplyr)
??dplyr

# readxl: import Excel data
install.packages("readxl")
library(readxl)


read_and_prepare1 <- function(filename) {
  xl <- read_excel(filename)
  #df <- as.data.frame(xl) 
  name <- colnames(xl)[1]
  colnames(xl)[1] <- "Country"
  xl = data.frame(xl["Country"], xl["2002.0"])
  colnames(xl)[2] <- name
  return(xl)
}

lung_cancer_incidence_male <- read_and_prepare1("indicator lung male incidence.xlsx")
lung_cancer_incidence_female <- read_and_prepare1("indicator lung female incidence.xlsx")

mortality_male <- read_and_prepare1("indicator lung male mortality.xlsx")
mortality_female <- read_and_prepare1("indicator lung female mortality.xlsx")

read_and_prepare2 <- function(filename) {
  xl <- read_excel(filename)
  name <- colnames(xl)[1]
  data <- xl[,c(1, 2)]
  colnames(data)[1] <- "Country"
  colnames(data)[2] <- "Prevalence of tobacco use"  #name
  return(data)
}

smoking_prevalence_male <- read_and_prepare2("indicator_prevalence of current tobacco use among adults (%) male.xlsx")
smoking_prevalence_male
smoking_prevalence_female <- read_and_prepare2("indicator_prevalence of current tobacco use among adults (%) female.xlsx")
smoking_prevalence_female

# next steps:
# 1) create using dplr joins, compare male and female (gives two prints for smoking and country)
# 2) create 2D plots smoking rate vs. mortality for each gender. Maybe use tidyr if applicable.
result <- left_join(lung_cancer_incidence_male, smoking_prevalence_male, by = "Country")
qplot(data = result, x=`Prevalence of tobacco use`, y=`Lung Male Incidence`, 
      label = Country, 
      main = "Tobacco use and lung cancer (Male)", 
      xlab  = "Prevalence of tobacco use (per 100)",
      ylab = "Lung cancer incidents per 100,000 in 2002") + geom_text(size=2, vjust=-1.4)
ggsave("Tobacco use and lung cancer (male).png")

result_fe <- left_join(lung_cancer_incidence_female, smoking_prevalence_female, by = "Country")
qplot(data = result_fe, x=result$`Prevalence of tobacco use`, 
      y = `Lung Female Incidence`, 
      label = Country, 
      main = "Tobacco and lung cancer (Female)", 
      xlab  = "Prevalence of tobacco use (per 100)",
      ylab = "Lung cancer incidents per 100,000 in 2002") + geom_text(size=2, vjust=-1.4)
ggsave("Tobacco use and lung cancer (female).png")

# Finally, create a joint plot to show the difference between male and female.
# First, join the data of male and female.
# Then use gather() to create a variable "gender" from the data.
combined_cancer <- inner_join(lung_cancer_incidence_female, lung_cancer_incidence_male, by = "Country")
colnames(combined_cancer)[2:3] <- c("Female", "Male")
combined_cancer <- gather(combined_cancer, "Gender", "LungCancerIncidents", 2:3)

combined_smoking <- inner_join(smoking_prevalence_female, smoking_prevalence_male, by = "Country")
colnames(combined_smoking)[2:3] <- c("Female", "Male")
combined_smoking <- gather(combined_smoking, "Gender", "SmokersPer100", 2:3)

#combined <- inner_join(combined_cancer, combined_smoking, by = )
# Use R's merge instead
combined = merge(combined_cancer, combined_smoking)

qplot(data = combined, 
      x=SmokersPer100, 
      y=LungCancerIncidents, 
      color=Gender, 
      label=Country,
      main="Tobacco use and lung cancer, male and female",
      xlab="Smokers per 100",
      ylab="Incidents of lung cancer per 100,000") + 
  geom_text(size=2, vjust=-1.4)
ggsave("Tobacco use and lung cancer (female vs. male).png")
