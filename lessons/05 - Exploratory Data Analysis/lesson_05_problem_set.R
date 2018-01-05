library(dplyr)
library(ggplot2)
setwd("/home/jonas/workspace/udacity/lessons/05 - Exploratory Data Analysis/")
?diamonds

# 
names(diamonds)
colnames(diamonds)
sapply(diamonds, mode)
sapply(diamonds, class)
table(diamonds$color)

# 1) Price histogram, faceted by color, coloured by cut 
ggplot(data = diamonds,
       aes(price)) +
  facet_wrap( ~ color) +
  geom_histogram(aes(fill = cut)) + 
  #scale_fill_brewer(type = 'qual') +
  scale_x_log10()

# 2) Price vs. table colored by cut
ggplot(data = diamonds,
       aes(x = table, y = price, color = cut)) +
  geom_point() +
  scale_color_brewer(type = 'qual')


# 3) Typical table value
# Read typical table values from the graph (refine plot for premium cut, it might be overplotted)
ggplot(data = subset(diamonds, cut == "Premium"),
       aes(x = table, y = price, color = cut)) +
  geom_point() +
  scale_color_brewer(type = 'qual')
# As it turned out, the refinedment was too much. The grader does not seem to have noticed that 
# there are _many_ diamonds of premium cut with a table value in [54,56]

# 4) Price vs. volume and diamond clarity
threshold <- quantile(diamonds$x * diamonds$y * diamonds$z, 0.99)
ggplot(data = subset(diamonds, x * y * z <= threshold),
       aes(x = x * y * z, y = price, color = clarity)) + 
  geom_point() +
  scale_y_log10() + 
  scale_color_brewer(type = 'div')

# 5) Proportions of friendships initiated
pf <- read.delim('pseudo_facebook.tsv')
pf$prop_initiated <- ifelse(pf$friend_count > 0, pf$friendships_initiated / pf$friend_count, 0)

# 6) prop_initiated vs. tenure
pf$year_joined <- floor(2014 - pf$tenure / 365)
pf$year_joined.bucket <- cut(pf$year_joined, breaks = c(2004, 2009, 2011, 2012, 2014))
ggplot(data = pf,
       aes(x = tenure, y = prop_initiated)) + # , color = year_joined.bucket)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median)

# 7+8) Smoothing prop_initiated vs. tenure
ggplot(data = pf,
       aes(x = 100 * floor(tenure / 10), y = prop_initiated)) + 
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) 

# 9) Group with largest mean, and what is it.
groups <- group_by(pf, year_joined.bucket)
summarize(groups,
          mean_prop_initiated = mean(prop_initiated),
          n = n())

# 10) Price/carat ratio binned, faceted by color
ggplot(data = diamonds,
       aes(x = cut, y = price / carat, color = color)) +
  geom_point() + 
  facet_wrap( ~ clarity) + 
  scale_color_brewer(type = 'div')

# 11) Gapminder multivariate analysis

# Continue the last exercise with additional data for renewable energy sources or so.
library(tidyr)
library(readxl)

load_and_prepare_data <- function(xls_file, metric_name) {
  xl <- read_excel(xls_file)
  xl <- gather(xl, key = "Year", value = !!metric_name, 2:ncol(xl), convert = TRUE)
  colnames(xl)[1] = "Country"
  return(xl)
}

production.oil.per.capita <- load_and_prepare_data("Oil Production per capita.xls.xlsx", "Oil_production")
production.gas.per.capita <- load_and_prepare_data("Natural gas Production per capita.xls.xlsx", "Natural_gas_production")
production.nuclear.per.capita <- load_and_prepare_data("Indicator_Nuclear production per capita.xlsx", "Nuclear_production")
production.hydro.per.capita <- load_and_prepare_data("Indicator_Hydro production per capita.xlsx", "Hydro_electricity_production")
consumption.coal.per.capity <- load_and_prepare_data("Coal Consumption per capita.xls.xlsx", "Coal_consumption")

# Fixes for indiviual data sets:
sapply(production.gas.per.capita, mode)
production.gas.per.capita$Natural_gas_production <- as.numeric(production.gas.per.capita$Natural_gas_production)
sapply(production.gas.per.capita, mode)

field <- colnames(production.oil.per.capita)[3]
subset(production.oil.per.capita, !is.na(production.oil.per.capita[,ncol(production.oil.per.capita)]))

# This function helps to determine years with many data points.
get_year_with_most_na_entries <- function(data) {
  non_na <- subset(data, !is.na(data[,ncol(data)]))
  year_groups <- group_by(non_na, Year)
  year_and_count <- summarize(year_groups, 
                              n = n())
  index <- which.max(year_and_count$n)
  return(year_and_count[index,1])
}
get_year_with_most_na_entries(production.gas.per.capita)
get_year_with_most_na_entries(production.oil.per.capita)

# Copied from lesson 4 problem set:
CO2.emissions <- load_and_prepare_data("indicator CDIAC carbon_dioxide_emissions_per_capita.xlsx", "CO2_emissions")
energy.use <- load_and_prepare_data("energy use per person.xlsx", "Energy_use")
combined <- inner_join(CO2.emissions, energy.use)  # default "by" will use all common column names

# Add a third dimension (color) to the plot:
combined_plot <- function(third_dimension, selected_year = 2010) {
  tmp_combined <- inner_join(combined, third_dimension, on ="Country")
  print(names(tmp_combined))
  fieldname_of_third_dimension = colnames(tmp_combined)[5]
  data2010 <- subset(tmp_combined, Year == selected_year & !is.na(Energy_use) & !is.na(CO2_emissions))
  ggplot(data = data2010, 
         aes_string(x = "Energy_use", y = "CO2_emissions"
             , color = fieldname_of_third_dimension
             , label = ifelse("Energy_use" > quantile(data2010$Energy_use, 0.85) | "CO2_emissions" > quantile(data2010$CO2_emissions, 0.85), "Country", "")
         )) +
    geom_point(size = 2) +
    scale_color_gradient(low = "blue", high = "red") +
    geom_text(size = 3, vjust=-1.4) + 
    coord_trans(x = "sqrt", y = "sqrt") +
    ggtitle(paste("Energy use and CO2 emission vs. energy source in", selected_year)) +
    xlab("Energy use per capita (tons of oil equivalent)") +
    ylab("CO2 emission per capita (tons of CO2)") 
}


combined_plot(production.oil.per.capita)
ggsave("Energy_source_oil_and_CO2_emissions_2010.png")

combined_plot(production.nuclear.per.capita)
ggsave("Energy_source_nuclear_and_CO2_emissions_2010.png")

combined_plot(production.hydro.per.capita)
ggsave("Energy_source_hydro_and_CO2_emissions_2010.png")

combined_plot(consumption.coal.per.capity)
ggsave("Energy_source_coal_and_CO2_emissions_2010.png")

subset(production.gas.per.capita, Year == 2008)[c("Country", "Natural_gas_production")]
combined_plot(production.gas.per.capita, 2008)
ggsave("Energy_source_natural_gas_and_CO2_emissions_2008.png")
