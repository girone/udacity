library(ggplot2)
library(dplyr)
setwd("/home/jonas/workspace/udacity/lessons/05 - Exploratory Data Analysis")
getwd()

data(diamonds)  # load data set (comes with ggplot2)

# 1+2) Scatterplot price vs. x
ggplot(data = diamonds, aes(x = price, y = x)) +
  geom_point()

# 3) Correlation of price vs. x, y and z
cor.test(diamonds$price, diamonds$x)
cor.test(diamonds$price, diamonds$y)
cor.test(diamonds$price, diamonds$z)

# 4+5) Scatterplot price vs. depth
ggplot(data = diamonds, aes(y = price, x = depth)) + 
  geom_point(alpha = 1/100) + 
  scale_x_continuous(breaks = seq(40, 80, 2))

# 6) Distribution of "depth"
summary(diamonds$depth)

# 7) Correlation price vs. depth
cor.test(diamonds$depth, diamonds$price)

# 8) Scatterplot of price vs. carat, omit top 1% of x and y
ggplot(data = diamonds, aes(x = carat, y = price)) + 
  xlim(0, quantile(diamonds$carat, 0.99)) +
  ylim(0, quantile(diamonds$price, 0.99)) +
  geom_point()

# 9+10) Create a new variable x*y*z and a scatterplot of price vs. that variable
diamonds$volume = diamonds$x * diamonds$y * diamonds$z
ggplot(data = diamonds, aes(x = volume, y = price)) +
  geom_point()

# 11) Correlation of a subset
with(diamonds, cor.test(volume, price))
with(subset(diamonds, volume > 0 & volume < 800), cor.test(volume, price))

# 12) Plot of the subset, with alpha < 1 and fitted model
?geom_smooth
ggplot(data = subset(diamonds, volume > 0 & volume < 800), aes(x = volume, y = price)) +
  geom_point(alpha=0.01) +
  geom_smooth(method="lm")

# 13) Group by clarity, create group statistics
clarity_groups <- group_by(diamonds, clarity)
diamondsByClarity <- summarize(clarity_groups, 
                               mean_price = mean(price), 
                               median_price = median(price), 
                               min_price = min(price), 
                               max_price = max(price),
                               n = n())

# 14+15) Create bar charts to compare two groupings. geom_bar() vs. geom_col()
library(gridExtra)

diamonds_by_clarity <- group_by(diamonds, clarity)
diamonds_mp_by_clarity <- summarise(diamonds_by_clarity, mean_price = mean(price))
p1 <- ggplot(data = diamonds_mp_by_clarity, aes(x = clarity, y = mean_price)) +
  geom_col()

diamonds_by_color <- group_by(diamonds, color)
diamonds_mp_by_color <- summarise(diamonds_by_color, mean_price = mean(price)) 
p2 <- ggplot(data = diamonds_mp_by_color, aes(x = color, y = mean_price)) +
  geom_col()

grid.arrange(p1, p2, ncol=1)

# According to the instructor slides, mean prices are decreasing for both 
# clarity and color. I can only observe this for  clarity.

# 16) Gapminder data
# Let's investigate the relation between CO2 emissions and energy consumption per person.
library(readxl)
library(tidyr)
library(dplyr)
library(grid)
library(gridExtra)
library(ggplot2)
xl <- read_excel("indicator CDIAC carbon_dioxide_emissions_per_capita.xlsx")
xl2 <- read_excel("energy use per person.xlsx")
# Collapse year columns into one column for a variable "year" using tidyr's gather().
co2_emission <- "CO2 emissions per capita"
xl <- gather(xl, "year", co2_emission, 2:254)
colnames(xl)[1] <- "country"
energy_use <- "energy use per capita"
xl2 <- gather(xl2, "year", energy_use, 2:53)
colnames(xl2)[1] <- "country"

# There is a type mismatch in the colums (as seen in head()) or like this:
sapply(xl, mode)
sapply(xl, class)
sapply(xl2, mode)
sapply(xl2, class)
# We need to fix it to be able to do the join:
# Alternative: Add "convert = TRUE" to gather() above.
xl <- transform(xl, year = as.numeric(year))
xl2 <- transform(xl2, year = as.numeric(year))

joint <- inner_join(xl, xl2)  # default "by" will use all common column names

# Check the relation for 2010 (year with most data) in a scatter plot:
data2010 <- subset(joint, year == 2010 & !is.na(energy_use) & !is.na(co2_emission))
ggplot(data = data2010, 
       aes(x = energy_use, y = co2_emission
#           , label = country
           , label = ifelse(energy_use > quantile(data2010$energy_use, 0.85) | co2_emission > quantile(data2010$co2_emission, 0.85), country, "")
           )) +
  geom_point(color = "blue") + 
  geom_text(size = 2, color = "blue", vjust=-1.4) + 
  #coord_trans(x = "sqrt", y = "sqrt") +
  ggtitle("Energy use and CO2 emission (2010)") +
  xlab("Energy use (tons of oil equivalent per capita)") +
  ylab("CO2 emission (tons of CO2 per capita)") +
  #geom_smooth(color = "red", level = 0.95, span = 10, method = "lm", formula = y ~ splines::bs(x, 3)) 
  geom_smooth(color = "red", level = 0.99, span = 1, n = 10, method = "lm") 
  #geom_smooth(color = "red", level = 0.95, span = 10) 
              
ggsave("energy_consumption_and_CO2_emission_per_capita.png")

# Analysis:
# There is clearly a relation between energy consumption and CO2 emissions among the countries of the world. This is also shown py Pearson's correlation coefficient r:
cor.test(data2010$energy_use, data2010$co2_emission)
# A value of > 0.8 means that the more energy is consumed per person, the larger the CO2 emissions are. Interestingly, there are some outliers. 
# * Iceland: Has a large energy consumption per capita, but a low CO2 emissions. This has two sources: For one, Iceland is quite cold and people need to heat a lot, leading to a high energy consumption. On the other hand, Icelanders use geothermal energy sources to heat up water and generate power, thus not many fossil fuel has to be burned, leading to a relatively small CO2 emission.
# * Sweden: AFAIK the Swedish use nuclear power to generate electricity, thus less fossil burnings.
# * Singapore: As a city state, Singapore probably does not generate its energy by itself but rather imports it from neighboring Malaysia. Thus it has small energy CO2 emissions by itself.
# * Kuwait, Qatar, Trinidad and Tobago: These states have plenty of oil or gas sources, thus energy comes at a low price and is used a lot, leading to high consumption at high emissions.


# Another plot: Development in Germany over time.
dataGermany <- subset(joint, country == "Germany")
plot1 <- ggplot(data = dataGermany, aes(y = co2_emission, x = year)) + 
  geom_col() +
  xlab("Year") +
  ylab("CO2 emission")
plot2 <- ggplot(data = dataGermany, aes(y = energy_use, x = year)) +
  geom_col() +
  ylab("Energy use") +
  xlab("Year") 
grid.arrange(plot1, plot2, ncol=1, top=textGrob("Energy use and CO2 emission in Germany"))
g <- arrangeGrob(plot1, plot2, ncol=1, top=textGrob("Energy use and CO2 emission in Germany"))
ggsave("energy_consumption_and_CO2_emission_in_Germany.png", g)

# Analysis:
# The energy use in Germany has been increasing steadily until the mid 80's, with a large increase in 1969. This might be due to a changed way to measure the energy use. Since the mid 80's, the energy use is slowly decreasing, maybe due to improved awareness for environmental consequences of high emissions and climate change.
# The CO2 emissions are decreasing since the same time, with a sudden drop in 1990. This drop is probably because of the union with former GDR, which changed the both the population size and total CO2 emissions. The general decrease can be explained with more efficient power stations and increasing share of renewable energy and nonfossil burnings.
