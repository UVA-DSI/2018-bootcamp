# Introduction to R: programming in R
# July 2017
# Clay Ford
# UVa Library Research Data Services

library(tidyverse)

# set working directory to R folder in 2018-bootcamp
setwd("/Users/jcf2d/2018-bootcamp/R/")

# load data from part 3
load("data/introR3.Rda")

# The R programming language allows us to automate repetitive tasks and create
# new functions. 

# Rule of thumb from R for Data Science: if you find yourself copying and
# pasting code and modifying variables, it may be time to write a function.

# Of course consider the time it will take to create the function versus the
# time it will take to simply get the job done by copying and pasting!

# Books on R Programming:
# R for Data Science: http://r4ds.had.co.nz/ (The Program chapter)
# Hands on Programming with R, by Garrett Grolemund
# Art of R Programming, by Norman Matloff
# Advanced R, by Hadley Wickham: http://adv-r.had.co.nz/
# R Packages, by Hadley Wickham: http://r-pkgs.had.co.nz/ 
# Software for Data Analysis, Programming with R, by John Chambers 


# Creating functions ------------------------------------------------------

# R comes with many functions, such as mean, median, sd, cor, and so on. But R 
# allows you to easily write your own functions. To do so, you use the 
# function() function, with arguments of your own creation.

# Here's a simple function that calculates a polynomial

form1 <- function(x) 4*x^2 + 0.3*x + 2      # f(x) = 4*x^2 + 3*x + 2
form1(x = 4)
form1(x = 100:120)
plot(x = seq(-1000,1000,10), 
     y = form1(x = seq(-1000,1000,10)), 
     type = "l")

# In the function argument we define an argument called "x". After that we
# create an expression that takes the value of "x". Sort of like f(x) = 4*x^2 +
# 3*x + 2. We determine the argument name. I used "x" but I could have chosen
# "num", "value", "data", etc.

# This function is temporary. It will be removed from memory as soon as I close
# R/RStudio.

# We can write functions with more than one argument. Here's a function that
# calculates body mass index (BMI) in pounds:
bmi <- function(weight, height) (weight/(height^2))*703

# We can also use curly braces if our functions contain more than one line of
# code.
bmi <- function(weight, height) {
  ratio <- weight/(height^2)
  ratio*703
  }


bmi(weight=215, height=69)
bmi(weight=c(168,215,199), height=c(68,69,72))

# Let's say I have a data frame of weights and heights; Randomly generate some
# data, making weight a function of height with some noise.
dat <- tibble(height = rnorm(25, 68, 4),
              weight = -140 + 5 * height + rnorm(25,0,20))
plot(dat)

# I can use my function to calculate BMI for all records 
dat <- dat %>% mutate(bmi = bmi(weight, height))
head(dat)

# Of course this could have been done without a function:
dat <- dat %>% mutate(bmi = (weight/(height^2))*703)

# Functions can have output consisting of multiple values. Use c(), list(),
# data.frame(), etc. For example return a data frame that includes weight,
# height and bmi.
bmi <- function(weight, height) {
  ratio <- weight/(height^2)
  bmi <- ratio*703
  data.frame(weight = weight, height = height, bmi = bmi)
}

bmi(weight=215, height=69)
bmi(weight=c(168,215,199), height=c(68,69,72))


# Functions can also be "anonymous", that is they are created on the fly and not
# saved in the global environment. This is often done with "apply" functions.

# Recall the anscombe data that come with R
anscombe

# "apply" a function to all the columns that returns the mean and standard
# deviation. Notice below we create a function "on the fly".

# lapply returns a list
lapply(anscombe, function(x)c(mean = mean(x), sd = sd(x)))

# sapply attempts to simplify the output
sapply(anscombe, function(x)c(mean = mean(x), sd = sd(x)))

# The tidyverse purrr package provides alternatives to lapply/sapply called map
map(anscombe, function(x)c(mean = mean(x), sd = sd(x)))

# To simplify, use variations of map to specify output.
# Data frame
map_df(anscombe, function(x)c(mean = mean(x), sd = sd(x)))

# or pipe into as.data.frame()
map(anscombe, function(x)c(mean = mean(x), sd = sd(x))) %>% 
  as.data.frame()


# Can also use a special formula notation to define anonymous functions using
# map.
map(anscombe, ~ c(mean = mean(.x), sd = sd(.x)))

# Use apply() to apply functions down columns or across rows of matrices.
mat <- matrix(data = rnorm(50, 10, 1), nrow = 5)
mat
apply(mat, 1, mean) # rows
apply(mat, 2, mean) # columns
apply(mat, 1, function(x)diff(range(x))) # range of numbers in rows


# lapply/map and custom functions can be combined to automate tasks and allow us
# to not copy-and-paste code.



# Extended example - stock runs -------------------------------------------

# What were the longest runs of either increasing or decreasing opening prices
# for the stocks?

# Do bbby first.
bbby_open <- stocks_long %>% 
  filter(company == "bbby" & price_type=="Open") %>% 
  arrange(Date) %>% 
  mutate(d = c(NA,diff(price)),
         sign = sign(d))

# find streaks using run length encoding function (rle)  
rle.out <- rle(bbby_open$sign)
rle.out
rle.out$values
rle.out$lengths
table(rle.out$lengths) # table of runs; longest run is 7 days

# find when the run occured;
# maximum number of days with subsequent increase or decrease
m <- max(rle.out$lengths)

# The index right before the streak begins
k <- which.max(rle.out$lengths) - 1

# recreate sequence of signs leading up to beginning of streak
start <- length(rep(rle.out$values[1:k], rle.out$lengths[1:k]))

# summarize start and end of streak, length of streak, and change in price
bbby_open %>% 
  slice((start + 1):(start + m)) %>% 
  summarize(company = unique(company),
            start = min(Date),
            end = max(Date),
            streak = n(),
            change = diff(range(price)))

# Now let's write a function to do this for all stocks

# First get the names of all the stocks
companies <- unique(stocks_long$company)
names(companies) <- companies

# And now write the function; basically copy-and-paste the code we did above
# into curly braces and substiute an x for "bbby" and substitute "tmp" for "bbby_open"
streaks <- function(x){
  tmp <- stocks_long %>% 
    filter(company == x & price_type=="Open") %>% 
    arrange(Date) %>% 
    mutate(d = c(NA,diff(price)),
           sign = sign(d))
  
  # find streaks using run length encoding function (rle)  
  rle.out <- rle(tmp$sign)
  rle.out
  rle.out$values
  rle.out$lengths
  table(rle.out$lengths) # table of runs; longest run is 7 days
  
  # find when the run occured;
  # maximum number of days with subsequent increase or decrease
  m <- max(rle.out$lengths)
  
  # The index right before the streak begins
  k <- which.max(rle.out$lengths) - 1
  
  # recreate sequence of signs leading up to beginning of streak
  start <- length(rep(rle.out$values[1:k], rle.out$lengths[1:k]))
  
  # summarize start and end of streak, length of streak, and change in price
  tmp %>% 
    slice((start + 1):(start + m)) %>% 
    summarize(company = unique(company),
              start = min(Date),
              end = max(Date),
              streak = n(),
              change = diff(range(price)))
}

# test
streaks("bbby")
streaks("flws")

# Now map or lapply to companies
map_df(companies, streaks)
lapply(companies, streaks) %>% do.call(rbind, .)

# What if there are multiple streaks? How might we change the code?




# Extended example - bar charts -------------------------------------------

# Back to the Instacart data.

# Let's create a bar chart of the number of times products were purchased from
# the "soft drinks" aisle by day of week and save as a PDF

# First create a folder to store charts and set that as working directory
dir.create("charts")
setwd("charts")

# Now create bar chart
all_orders %>% 
  filter(aisle == "soft drinks") %>% 
  ggplot(aes(x = order_dow)) + 
  geom_bar() +
  scale_x_continuous(breaks = 0:6) +
  labs(x = "day of week", title = "soft drinks")
ggsave("softdrinks.pdf")
  

# Your boss tells you late Friday afternoon, "make a bar chart for every aisle
# before you leave today."

# There are 134 aisles
length(unique(all_orders$aisle))


# Let's automate with a function

# Copy and paste what we did before between the curly braces and replace "soft
# drinks" with x. We also add two lines to create a file and save the file
# without a message.
bar_chart <- function(x){
  all_orders %>% 
    filter(aisle == x) %>% 
    ggplot(aes(x = order_dow)) + 
    geom_bar() +
    scale_x_continuous(breaks = 0:6) +
    labs(x = "day of week", title = x)
  file_name <- gsub(" ", "_", x)
  suppressMessages(ggsave(paste0(file_name,".pdf")))
}

# test it out
bar_chart("soft drinks")

# Now "map" the function to the vector of aisle names using the purrr function
# map()
aisles <- unique(all_orders$aisle)
map(aisles, bar_chart)

# Base R: lapply(aisles, bar_chart)


# That makes our life easier, but not our boss's. She/He probably doesn't want
# to have to open and close 134 PDF files.

# How can we put them all into one file? R Markdown

# R Markdown is a way to combine R code and exposition to easily create reports
# and presentations.

# File...New File...R Markdown...

# Insert the following into a "code chunk", like so:

# ```{r}
# library(tidyverse)
# setwd("C:/Users/jcf2d/Desktop/r_bootcamp_data")  # change to your path
# load("introR3.Rda")
# 
# bar_chart <- function(x){
#   all_orders %>% 
#     filter(aisle == x) %>% 
#     ggplot(aes(x = order_dow)) + 
#     geom_bar() +
#     scale_x_continuous(breaks = 0:6) +
#     labs(x = "day of week", title = x)
# }
# 
# aisles <- unique(all_orders$aisle)
# map(aisles, bar_chart)
# ```

# RStudio provides a template to get you started. The cheatsheet is nice but can
# make it look more complicated than it really is when you're getting started.


# Potentially useful web page
# Using R Markdown for Class Reports
# http://www.stat.cmu.edu/~cshalizi/rmarkdown/




# End of class challenge --------------------------------------------------


# Imagine what your boss could ask of you and try to figure it out.

# For example...

# - Most popular products by day of week
# - Products most often reordered
# - Products that have never been reordered
# - Most popular time of day to place orders
# - Proportion of orders that are reordered products
# - Department with most/least orders
# - Aisle with most/least reorders
# - Products purchased together most often

# Here's how I attempted to answer these questions:
# http://people.virginia.edu/~jcf2d/instacart/instacart_analysis.R

# Better yet, generate your own questions.
