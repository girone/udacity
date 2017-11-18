library(ggplot2)
setwd("/home/jonas/workspace/udacity/lessons/05 - Exploratory Data Analysis/")
pf <- read.csv("pseudo_facebook.tsv", sep="\t")

qplot(x = age, y = friend_count, data = pf)
qplot(age, friend_count, data=pf)  # shorthand
summary(pf$age)

# Better plot and more options with ggplot
# Reminder: aes ... aesthetic wrapper
ggplot(aes(x = age, y = friend_count), data = pf) + 
  geom_point() + 
  xlim(13, 90)

# observation: a lot of overplotting
# solution: add alpha parameter
ggplot(aes(x = age, y = friend_count), data = pf) + 
  geom_point(alpha = 1/20) + 
  xlim(13, 90)

# observation: buckets of discrete variables lead to "stripy" distribution
# oslution: use jitter instead of point
ggplot(aes(x = age, y = friend_count), data = pf) + 
  geom_jitter(alpha = 1/20) + 
  xlim(13, 90)

# transform y axis
?coord_trans
ggplot(aes(x = age, y = friend_count), data = pf) + 
  geom_point(alpha = 1/20, position = position_jitter(h=0)) + 
  xlim(13, 90) + 
  coord_trans(y = "sqrt")  # compare to layers scale_x_log10() and scale_y_sqrt()

# Different relation
ggplot(aes(x = age, y = friendships_initiated), data = pf) +
  geom_point(alpha = 1/20, position = position_jitter(h=0)) +
  xlim(13, 90) + 
  coord_trans(y = "sqrt")

# Use dplyr for transformations
library(dplyr)

# Compute conditional means and medians
age_groups = group_by(pf, age)
pf.fc_by_age <- summarize(age_groups, 
          friend_count_mean = mean(friend_count),
          friend_count_median = median(friend_count),
          n=n())
head(pf.fc_by_age)

# another way to write this: use the %>% chaining syntax
pf.fc_by_age <- pf %>%
  group_by(age) %>%
  summarise(friend_count_mean = mean(friend_count),
            friend_count_median = median(friend_count),
            n = n()) %>%
  arrange(age)
  
# line plot
ggplot(aes(x = age, y = friend_count_mean), data = pf.fc_by_age) +
  geom_line()

# overlaying summaries with raw data
ggplot(aes(x = age, y = friend_count), data = pf) + 
  geom_point(alpha = 1/20, 
             position = position_jitter(h=0), 
             color = "orange") + 
  coord_cartesian(xlim = c(13, 70), ylim = c(0, 1000)) +
  geom_line(stat = "summary", fun.y = mean) + 
  geom_line(stat = "summary", fun.y = median, color = "blue") +
  geom_line(stat = "summary", fun.y = quantile, fun.args=list(probs=0.1), linetype = 2, color = "blue") +
  geom_line(stat = "summary", fun.y = quantile, fun.args=list(probs=0.9), linetype = 2, color = "blue")

# Correlation (Pearson's r)
?cor.test
cor.test(pf$age, pf$friend_count, method = "pearson")

# with function
?with
with(subset(pf, age >= 13 & age <= 70), cor.test(age, friend_count))

# scatterplots
ggplot(aes(x = www_likes_received, y = likes_received), data = pf) +
  geom_point(alpha = 1/20) + 
  xlim(0, quantile(pf$www_likes_received, 0.95)) +
  ylim(0, quantile(pf$likes_received, 0.95)) +
  geom_smooth(method = "lm", color = "red")

cor.test(pf$www_likes_received, pf$likes_received)

# correlation can be deceiptive if two variables
#install.packages("alr3")  # does not work as of 2017/11/05
#library(alr3)
#data(Mitchell)
#?Mitchell
#ggplot(data = Mitchell, aes(x = Month %% 12, y = Temp)) +  # %% ... modulo operator
#  geom_point() +
#  scale_x_discrete(breaks = seq(0, 203, 12))


# Noise in data
## Explore conditional mean based on age in months
pf$age_with_months <- with(pf, age + 1 - dob_month / 12)
head(pf$age_with_months)
summary(pf$age_with_months)

# intuitive solution which does not pass the grader:
pf.fc_by_age_months <-
  pf %>%
  group_by(age_with_months) %>%
  summarize(friend_count_mean = mean(friend_count),
            friend_count_median = median(as.numeric(friend_count)),
            n = n()) %>%
  arrange(age_with_months)
head(pf.fc_by_age_months)

# alternative way which passes the grader:
age_groups <- group_by(pf, age_with_months)
pf.fc_by_age_months <- summarise(age_groups,
                          friend_count_mean = mean(friend_count),
                          friend_count_median = median(friend_count),
                          n = n())
pf.fc_by_age_months <- arrange(pf.fc_by_age_months, age_with_months)

# compare with the plot by age in years, having multiple plots in on graph

p2 <- ggplot(data = subset(pf.fc_by_age_months, age_with_months < 71), 
       aes(x = age_with_months, y = friend_count_mean)) + 
  geom_line()

p1 <- ggplot(data = subset(pf.fc_by_age, age < 71),
             aes(x = age, y = friend_count_mean)) +
  geom_line()

library(gridExtra)
grid.arrange(p1, p2, ncol=1)

# Compare to local regression (LOESS) http://simplystatistics.org/2014/02/13/loess-explained-in-a-gif/

p3 <- ggplot(data = subset(pf, age < 71),
             aes(x = round(age / 5) * 5, y = friend_count)) +
  geom_line(stat = "summary", fun.y = mean)

grid.arrange(p1, p2, p3, ncol=1)

# Built-in way: geom_smooth()

p2 <- ggplot(data = subset(pf.fc_by_age_months, age_with_months < 71), 
             aes(x = age_with_months, y = friend_count_mean)) + 
  geom_line() +
  geom_smooth()

p1 <- ggplot(data = subset(pf.fc_by_age, age < 71),
             aes(x = age, y = friend_count_mean)) +
  geom_line() +
  geom_smooth()

grid.arrange(p1, p2, p3, ncol=1)


# TODO(Jonas): As a review, summarize this lesson in Markdown