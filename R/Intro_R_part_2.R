# Introduction to R: data wrangling and visualization
# July 2018
# Clay Ford
# UVa Library Research Data Services

library(tidyverse)

# Load data from Intro_R_part_1
load("data/introR1.Rda")


# dplyr intro -------------------------------------------------------------

# From the dplyr vignette:

# dplyr 'provides simple "verbs", functions that correspond to the most common
# data manipulation tasks, to help you translate your thoughts into code.'



# dplyr: rename -----------------------------------------------------------

# change column/variable names with rename()

# Change "chronname" to "university", and "grad_100_value" to "grad100" 
# rename(data, new name = old name)
names(college)
college <- rename(college, 
                  university = chronname,
                  grad100 = grad_100_value)

# Base R equivalent:
# names(college)[c(2,20)] <- c("university","grad100")



# dplyr: select -----------------------------------------------------------

# select: keep identified columns
# Make an abbreviated dataset
colBrief <- select(college, university, level, control, student_count)
colBrief <- select(college, university:basic)
colBrief <- select(college, -unitid) # keep all columns except unitid
colBrief <- select(college, -university:-basic) # keep all columns except university:basic

# drop columns that end with "value", notice the minus sign
colBrief <- select(college, -ends_with("value"))

# select() helper functions: starts_with(), ends_with(), matches(), contains()

# Base R equivalent: 
# subset(college, select=c(university, level, control, student_count))
# subset(college, select=university:basic)
# subset(college, select = -unitid)
# subset(college, select = -university:-basic)
# subset(college, select=grep("value$", names(college), invert = T))



# dplyr: filter -----------------------------------------------------------


# filter: keep observations that satisfy conditions
# Make a dataset of 4-year colleges and of 4-year public colleges
col4year <- filter(college, level == "4-year")
col4public <- filter(college, level == "4-year" & control == "Public")

# or a dataset of colleges with enrollment over 10,000
col_10k <- filter(college, student_count > 10000)


# Base R: 
# subset(college, level == "4-year")
# subset(college, level == "4-year" & control == "Public")
# subset(college, student_count > 10000)



# dplyr: recode -----------------------------------------------------------

# recode: replaces elements based on their values 

# recode works on a column, not an entire data frame

# Create a column called control2 that takes the value "Private" when control is
# "Private for-profit" or "Private not-for-profit", and otherwise "Public"
college$control2 <- recode(college$control, Public = "Public", .default = "Private")

# Base R: college$control2 <- factor(ifelse(college$control=="Public", "Public", "Private"))


# Can also be used to set missing values to, say, 0.
summary(college$endow_value)
college$endow <- recode(college$endow_value, .missing=0)

# Base R: college$endow <- ifelse(is.na(college$endow_value), 0, college$endow_value)



# dplyr: mutate -----------------------------------------------------------


# mutate: add new columns derived from existing columns

# - derive endow_total as endow * fte_value
# - derive endow_mil as endow_total / 1e6
# - derive full_time_students as (ft_pct/100) * student_count
college <- mutate(college, 
                  endow_total = endow * fte_value,
                  endow_mil = endow_total/1e6,
                  full_time_students = (ft_pct/100) * student_count)

# Base R:
# college <- within(college, {
#   endow_total <- endow * fte_value
#   endow_mil <- endow/1e6
#   full_time_students <- (ft_pct/100) * student_count
# })


# if_else: take a logical vector (e.g., a comparison) and replace 
#   TRUEs with one vector and FALSEs with another.

# Make hbcu and flagship a 0/1 indicator
table(college$hbcu)
table(college$hbcu, useNA = "ifany")
table(college$flagship, useNA = "ifany")

# If college$hbcu=="X", then set to 1, otherwise set to 0;
# But notice there are no FALSE values for this comparison
table(college$hbcu=="X", useNA = "ifany")

# Therefore we use is.na() to generate TRUE/FALSE
college <- mutate(college, 
                  hbcu2 = if_else(is.na(hbcu), true = 0, false = 1),
                  flagship2 = if_else(is.na(flagship), true = 0, false = 1))
table(college$hbcu2)
table(college$flagship2)

# if_else allows us to specify a missing value, so we can also do this:
# Notice the false argument cannot be left empty
college <- mutate(college, 
                  hbcu2 = if_else(hbcu=="X", true = 1, false = 0, missing = 0),
                  flagship2 = if_else(flagship=="X", true = 1, false = 0, missing = 0))
table(college$hbcu2)
table(college$flagship2)

# Base R: using within and ifelse;
# Base R ifelse has no "missing" argument
# college <- within(college, {
#   hbcu2 <- ifelse(is.na(hbcu), 0, 1)
#   flagship2 <- ifelse(is.na(flagship), 0, 1)
#   })


# dplyr: arrange ----------------------------------------------------------


# arrange: reorder/sort dataframe
# arrange by colleges with the worst on-time graduation rates
college <- arrange(college, grad100)
select(college, university, grad100) 

# Base R: college <- college[order(grad100),]

# arrange by colleges with the best on-time graduation rates
college <- arrange(college, desc(grad100))
select(college, university, grad100) 

# Base R: college <- college[order(grad100, decreasing = T),]



# dplyr: sample_frac and sample_n -----------------------------------------


# Sample rows from a data frame

# sample 10% of data without replacement
college_samp1 <- sample_frac(college, size = 0.10)

# Base R: 
# n <- nrow(college)
# college[sample(n, round(n * 0.10)),]

# sample 100 without replacement
college_samp2 <- sample_n(college, size = 100)

# Base R: 
# college[sample(nrow(college), 100),]


# To create testing and training sets, probably easier to use base R sample()
# with the dplyr function slice()

# 10% for testing, 90% for training
set.seed(123) # for reproducibility, if desired
n <- nrow(college)
test <- sample(n, round(n * 0.10)) # row numbers

# use the dplyr verb slice to select rows
college_test <- slice(college, test)
college_train <- slice(college, -test)

# 500 for test, the rest for training
test <- sample(n, 500)
college_test <- slice(college, test)
college_train <- slice(college, -test)


# Data Manipulation: pipe operator/chaining ------------------------------

# all the previous functions can be chained together with the pipe operator: 
# %>% 
# Shortcut: Ctrl/Command + Shift + M

# The %>% pipe is actually part of the magrittr package

# The pipe operator takes the result of the previous function and feeds it to
# the next function as the first argument.

# Basic Example:
sample(nrow(college), 5)
# with pipe:
nrow(college) %>% sample(5)

# Read as "and then": take the number of rows in college "and then" sample 5

# Using dplyr functions.

# take college, and then 
#      filter for flagship2 == 1 and endowment > 0, and then 
#      arrange by total endowment in descending order, and then
#      select the university and endow_mil columns:
college %>% 
  filter(flagship2 == 1 & endow_mil > 0) %>% 
  arrange(desc(endow_mil)) %>% 
  select(university, endow_mil) 

# If you want to see all rows, end pipe with as.data.frame()
college %>% 
  filter(flagship2 == 1 & endow_mil > 0) %>% 
  arrange(desc(endow_mil)) %>% 
  select(university, endow_mil) %>% 
  as.data.frame()

# can even end with a right arrow -> to save result
college %>% 
  filter(flagship2 == 1 & endow_mil > 0) %>% 
  arrange(desc(endow_mil)) %>% 
  select(university, endow_mil) -> flagships



# YOUR TURN #1 ------------------------------------------------------------

# Using the college data, try do the following with pipes:

# make a new data frame called col2year where...

# - grad_150_value is renamed to grad150
# - data is filtered for 2-year colleges
# - university, grad100, grad150, student_count, ft_pct, ft_fac_value are the only columns



# dplyr: summarize and group_by -------------------------------------------


# summarize and group_by: break dataframe into groups and calculate summary
# statistics on groups

# works great with pipes

# Average on-time graduation rate by control of college
college %>% 
  group_by(control) %>% 
  summarize(mean = mean(grad100, na.rm=TRUE))

# summarize can perform multiple summaries:
college %>% 
  group_by(control) %>% 
  summarize(grad100 = mean(grad100, na.rm=TRUE),
            aid_value = mean(aid_value, na.rm = TRUE))


# data wrangling and summarize functions can be piped together

# Find the average total endowment and on-time graduation rate for 
#   2-year public, 2-year NFP, 4-year public, and 4-year NFP institutions.
college %>% 
  mutate(endow_total = endow * fte_value) %>% 
  filter(control != "Private for-profit") %>% 
  group_by(level, control) %>% 
  summarize(mean_endow_total = mean(endow_total, na.rm=TRUE), 
            mean_grad_100 = mean(grad100, na.rm=TRUE))



# YOUR TURN #2 ------------------------------------------------------------

# Using the gapminder data and pipes....

### TASK 1

# - update the gm data frame so it has a column called "gdp" that contains the
# GDP for each country in each observed year (ie, gdpPercap * pop)



### TASK 2

# - print to the console the top 5 countries with the smallest GDP in 2007



### TASK 3

# - print to the console the mean gdpPercap for each continent.



### TASK 4

# - print to the conSole the mean life expectancy and mean GDP by year for Asia.



# Intro to ggplot2 --------------------------------------------------------

# loading the tidyverse package loads the ggplot2 package.

# The ggplot2 cheatsheet that comes with RStudio provides a great intro.

# Scatterplot
# On-time graduation by percent receiving Pell grants

# This creates an empty plotting region with pell_value mapped to the x axis and
# grad100 mapped to the y axis. The aes() function describes aesthetic mappings.
ggplot(college, aes(x = pell_value, y = grad100))

# Now use points to represent the data:
ggplot(college, aes(x = pell_value, y = grad100)) + geom_point()

# Typical workflow
p <- ggplot(college, aes(x = pell_value, y = grad100))
p + geom_point()

# Change static characteristics (not wrapped in aes)
p + geom_point(color="blue", shape=1, size=2, alpha=1/2)

# see ?points for shape (pch) codes

# Add color for a third variable; distinguish by control of college
p + geom_point(aes(color=control))
p + geom_point(aes(color=aid_value))

# Add color for third variable, change character for fourth variable
p + geom_point(aes(color=control, shape=level), alpha=1/2, size = 3)



# YOUR TURN #3 ------------------------------------------------------------

# Using the gapminder data:

# create a scatterplot of lifeExp (Y) and gdpPercap (X)
#   that distinguishes observations by continent


# Data Visualization/Exploration -----------------------------------------

# Continuing with the college data...
p <- ggplot(college, aes(x = pell_value, y = grad100))

# Adding layers; smoothed conditional mean (e.g., via loess or gam)
p + geom_point() + geom_smooth()

# You can change the defaults
p + geom_point() + geom_smooth(lwd=2, se=FALSE, method="lm", col="red")

# Two smooth lines with a legend
p + geom_point(shape = 1) + 
  geom_smooth(aes(color = "gam"), se=F) + 
  geom_smooth(aes(color = "lm"), method = "lm", se = F)

# Add aesthetics; pattern conditional on control
p + geom_point(aes(color=control)) + geom_smooth()
p + aes(color=control) + geom_point() + geom_smooth(se=F, lwd=2)

# Facetting; pattern conditional on control
p + geom_point() + geom_smooth() + facet_wrap(~ control)

# color points by level (2 year vs 4 year), set dot transparency to 1/3, add
# smooth lines, and facet by control
p + aes(color=level) + geom_point(alpha = 1/3) + 
  geom_smooth(se=F) + facet_wrap(~control)



# YOUR TURN #4 ------------------------------------------------------------

# Using the gapminder data...

# Make a scatter plot of lifeExp on the y-axis 
#   against year on the x, faceting on continent,
#   and add a fitted curve, smooth or lm.



# More Data Visualization/Exploration -------------------------------------


# Boxplots and friends; percent receiving Pell grants by control
p <- ggplot(college, aes(x=control, y=pell_value))
p + geom_boxplot()
p + geom_violin()
p + geom_violin() + geom_jitter(alpha=1/2, width=.1)

# Histograms and friends; distribution of percent of full-time faculty
p <- ggplot(college, aes(x = ft_fac_value))
p + geom_histogram()
p + geom_histogram(binwidth=2)
# Color by control
p + geom_histogram(aes(fill=control))
p + geom_histogram(aes(fill=control), position="identity", alpha=1/3)
# Or density plot
p + geom_density()
p + geom_density(aes(color=control))
p + geom_density(aes(fill=control), alpha=1/4)



# YOUR TURN #5 ------------------------------------------------------------

# Using the gapminder data,
# Examine the distribution of gdpPercap by continent for 2007



# Saving plots ------------------------------------------------------------

# Save last plot printed to screen (only works in interactive mode)
p <- ggplot(college, aes(x = pell_value, y = grad100))
p + aes(color=level) + geom_point(alpha = 1/3) + 
  geom_smooth(se = F) + facet_wrap(~control)
ggsave(file="myplot.png")

# Another way
p <- ggplot(college, aes(x = pell_value, y = grad100))
pfinal <- p + aes(color=level) + geom_point(alpha = 1/3) + 
  geom_smooth(se = F) + facet_wrap(~control)
pfinal
ggsave(pfinal, file="myplot.pdf", width=15, height=5)


# Final Comments ---------------------------------------------------------

# Good practice is to write an R script for data preparation and manipulation
# that ends by saving the analysis-ready data as an Rds or Rda file. Then write
# a separate analysis script that begins with loading the Rds/Rda file. You
# don't want to re-import and clean your data everytime you come back to work on
# a project.
save(gm, college, missendow, flagships, file="data/introR2.Rda")
