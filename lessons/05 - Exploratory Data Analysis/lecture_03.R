install.packages("ggplot2")
library(ggplot2)

# Load from TSV
setwd("~/workspace/udacity/lessons/05 - Exploratory Data Analysis")
pf <- read.csv("pseudo_facebook.tsv", sep = "\t")
names(pf)

# Investigate day of birth
qplot(x = dob_day, data = pf) +
#  scale_x_discrete(breaks = 1:31) +
  facet_wrap(~dob_month, ncol = 3)

# Investigate friend count
qplot(x = friend_count, data = pf, xlim = c(0, 1000))

qplot(x = friend_count, data = subset(pf, !is.na(gender)), binwidth = 10) +
  scale_x_continuous(limits = c(0, 1000), breaks = seq(0, 1000, 50)) +
  facet_wrap(~gender)

## Alternative way of putting these in the same graph:
qplot(x = friend_count, data = subset(pf, !is.na(gender)), binwidth = 25,
      geom = "freqpoly", color = gender) +
  scale_x_continuous(limits = c(0, 1000), breaks = seq(0, 1000, 50)) 

## Using relative proportions:
qplot(x = friend_count, y = ..count../sum(..count..), 
      data = subset(pf, !is.na(gender)),
      xlab = "Friend count",
      ylab = "Proportion of users with that friend count", 
      binwidth = 10,
      geom = "freqpoly", color = gender
      ) +
  scale_x_continuous(limits = c(0, 1000), breaks = seq(0, 1000, 50))

## Using boxplots (median, inner quartile range, outliers)
qplot(x = gender, y = friend_count, data = subset(pf, !is.na(gender)), 
      geom = "boxplot",
      #ylim = c(0, 1000)  # removes data points, instead use:
      ) +
  # scale_y_continous(limits = c(0, 1000)) +  # also removes data points, instead use:
  coord_cartesian(ylim = c(0, 1000))

## Create textual comparison of data:
table(pf$gender)
by(pf$friend_count, pf$gender, summary)

# Investigate tenure
qplot(x = tenure/365, data = pf, binwidth = .25,
      color = I("black"), fill = I("#099DD9"),
      xlab = "Number of years using Facebook",
      ylab = "Number of users") +
  scale_x_continuous(breaks = seq(1, 7, 1), limits = c(0, 7))

# Investigate ages
qplot(x = age, data = pf, binwidth = 1,
      color = I("black"), fill = I("#099DD9"))

# Transform data, create multiple plots in one.
install.packages('gridExtra')
library(gridExtra)

p1 = qplot(x = friend_count, data = pf) + scale_x_continuous()
p2 = qplot(x = log10(friend_count + 1), data = pf) + scale_x_log10()
p3 = qplot(x = sqrt(friend_count), data = pf) + scale_x_sqrt()
grid.arrange(p1, p2, p3, ncol=2)

## Different approach to this problem, using ggplot directly and the aestetic wrapper

p1 <- ggplot(aes(friend_count), data = pf) + geom_histogram()
p2 <- p1 + scale_x_log10()
p3 <- p1 + scale_x_sqrt()
grid.arrange(p1, p2, p3, ncol=1)

# Investigate www_likes (likes generated on the world wide web)
qplot(x = www_likes, y = ..count../sum(..count..), 
      data = subset(pf, !is.na(gender)),
      geom = "freqpoly", color = gender) +
  scale_x_continuous() +
  scale_x_log10()

by(pf$www_likes, pf$gender, sum)

