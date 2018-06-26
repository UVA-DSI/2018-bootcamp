# Introduction to R: R Basics, Reading/Inspecting/Saving Data
# July 2018
# Clay Ford
# UVa Library Research Data Services

# Preface comments with '#'



# keyboard shortcuts ------------------------------------------------------


# Three good keyboard shortcuts to know:
 
# (2) Comment/uncomment lines:
# Ctrl + Shift + C (Win/Linux)
# Command + Shift + C (Mac)

# (3) Reflow Comments:	
# Ctrl + Shift + / (Win/Linux)
# Command + Shift + / (Mac)

# (1) Enter code section headers: 
# Ctrl + Shift + R (Win/Linux) 
# Command + Shift + R (Mac)

# See all keyboard shortcuts: 
# Alt + Shift + K (Win/Linux)
# Option + Shift + K (Mac)


# Loading Libraries/Packages ----------------------------------------------

# You will almost always use packages in an R script. It's good practice to load
# those packages at the top of your script. 

# Today we will make heavy use of what are called the 'tidyverse' packages. 
# These are packages that share a common data representations and similar
# design.

# If you don't already have it, install the 'tidyverse' package. This package 
# will install 19 other packages. Either uncomment the line below and run the 
# code, or go to the Packages pane, click the Install button, enter 'tidyverse',
# and click install.

# install.packages("tidyverse")

# Then load the package (must do once per session):
library(tidyverse)

# This loads 8 packages. Notice the conflicts. This says dplyr has two 
# functions with the same name as functions in the stats package, which is 
# loaded when R is started. If we use filter() or lag(), we will use dplyr's 
# version, not the stats version. It now comes ahead of stats on the search
# path.
search()

# To use the stats version of filter() and lag(), preface the function with 
# "stats::" That's also how we can use any package's function without loading
# the package.

# We also need the readxl package to read in Excel files. This should have been
# installed with 'tidyverse'.
library(readxl)


# Set your working directory ----------------------------------------------

# The working directory is the default place a program looks for files or saves 
# files. Your working directory is usually where you keep your data files for a 
# project, assignment, etc. In this script, we want to set our working directory
# to where you downloaded the workshop data files.

# To set working directory via point-and-click:

# (1) Session...Set Working Directory...Choose Directory
# Or Ctrl + Shift + H

# (2) Use the Files tab. Navigate to folder and select "Set As Working
# Directory" under More

# To set working directory with R code:

# use setwd() function; path must be in quotes

# In RStudio, you can use the TAB key in the quotes to autocomplete the path.
# Try it! 

setwd("")

# Start with "/" to start from your root directory. 
# Start with "~/" to start from your home directory.
# Use ".." to go up one directory in the hierarchy.

# Please set your working directory to where you cloned the 2018-bootcamp repo,
# or downloaded the workshop files as the case may be.




# RStudio Projects --------------------------------------------------------

# RStudio Projects allow you to easily switch between projects (or assignments,
# homeworks, analyses, etc.)

# 1. Go to File...New Project
# 2. Pick either New Directory...Empty Project, or Existing Directory
# 3. Browse to, or create, your directory and click Create Project

# Now opening an R Project will set your working directory as well as open files
# you were previously working on.

# learn more at:
# https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects


# Getting data into R -----------------------------------------------------

# You can import just about any kind of data into R: Excel, Stata, SPSS, SAS, 
# CSV, JSON, fixed-width, TXT, DAT, shape files, and on and on. You can even 
# connect to databases. The best way to figure out how: Google "how to import 
# <type> files into R." This will usually involve installing and loading a
# special R package.

# Read an excel spreadsheet using read_excel (from readxl package)
college <- read_excel("data/collegeCompletion.xlsx")

# Can also read in data from URLs; the following is a CSV file. 
college_csv <- read_csv("http://people.virginia.edu/~jcf2d/data/collegeCompletion.csv")

# read_csv is part of the readr package; can also use read.csv() in base R.

# Import gapminder data
gm <- read_csv("data/gapminder.csv")

# see also the Import Dataset button in RStudio.

# college, college_csv and gm are "data frames".

# Other R data structures include
# - vector (1D, same data type)
# - matrix (2D, same data type)
# - array (3D or more, same data type)
# - list (general container for all types and shapes of data)


# Inspecting Data ---------------------------------------------------------

# Quick way: click the name in the Environment window

# print to console; not terribly useful 
college

# Note: "tibble" is a tidyverse data frame; it prints differently than a base R
# data frame

# How Base R prints a data frame
as.data.frame(college)
# Tip: Ctrl + L will clear console

# More useful
str(college) # structure of data frame, base R way
glimpse(college) # tidyverse way


# dimensions of data frame
dim(college)
# first 6 records
head(college) 
# summary of variables
summary(college) 

# YOUR TURN: Try the following functions on college and see what they do:
# tail, names, nrow, ncol, length


# Working with columns/rows of data --------------------------------------

# Use indexing brackets to select portions of data frame
# [row number(s),column number(s)/name(s)]

# show first 6 records of first 3 columns
# 1:6 = 1,2,3,4,5,6
college[1:6,1:3] 

# first six rows; same as head(college)
college[1:6,] 

# columns 2 and 3
college[,2:3] 

# can also use column names
college[,c("chronname","control")]

# first 10 records and all but first column
college[1:10,-1]


# Let's use this to read the data in again, more selectively.

# vector which indicates which column numbers to read in
colRead <- c(1:11,13,14,17,20,21,22,24,26,28,30,32,34,36)

# read in excel file, select certain columns, and assign to "college"
college <- read_excel("data/collegeCompletion.xlsx", sheet=1)[,colRead]
str(college)


# The dollar sign, $, allows us to access columns of data frame.

# Type college$ below and notice RStudio provides a drop down list of variables:


# First 6 values of student_count
head(college$student_count)

# first 10 values grad_100_value
college$grad_100_value[1:10] 

# number of fields in student_count
length(college$student_count)




# YOUR TURN: How can we view the last row of the college data frame without
# typing the row number?


# Summarizing data -------------------------------------------------------

# we can call summary() on columns:
summary(college$student_count)
summary(college$level)

# The second one was not very useful. level is a categorical value that takes 2 
# values. We can store categorical variables in R as a factor. A factor in R is
# stored as integers with associated "labels".

# Use as.factor() to convert a character column into a factor column
college$level <- as.factor(college$level)

# now summary() returns totals for each level
summary(college$level)

# Notice summary() did something different for college$student_count than it did
# for college$level. That's because summary() is a generic function that behaves
# differently depending on the class of the object it is used on. The "class" of
# an object is basically an attribute, or data about the data.
class(college$student_count)
class(college$level)

# We'll talk some more about classes and generic functions in part 4.

# Let's make other variables factors:
college$state <- as.factor(college$state)
college$control <- as.factor(college$control)
college$basic <- as.factor(college$basic)

# as.character, as.numeric, as.integer are other functions for converting data.

# NOTE: When do you use factor and when do you use character?

# If you plan to run ANOVA or linear models that involves your text data, you
# need to store your text data as Factors.

# If you plan to manipulate or use patterns of character data, for data cleaning
# or text mining, you want to store your text data as character.


# college$basic is a factor (ie, categorical variable)
# to see the levels, use the levels function
levels(college$level)
levels(college$basic)

# Note: levels does not work on a character vector
ch <- c("a", "a", "b", "d", "b")
levels(ch)
# instead we can use unique
unique(ch)
rm(ch)

# table() can calculate frequencies of a factor or character column
table(college$control)
table(as.character(college$control))

# summarize numeric columns
mean(college$grad_150_value)

# Why NA? There are missing values in grad_150_value column.
# We need to tell R to ignore the missing values in the calculation
# set na.rm=TRUE
mean(college$grad_150_value, na.rm=TRUE)

# Other summary stats
median(college$grad_150_value, na.rm=TRUE)
sd(college$grad_150_value, na.rm=TRUE) # standard deviation
range(college$grad_150_value, na.rm=TRUE) # returns min and max values
quantile(college$grad_150_value, na.rm=TRUE)
quantile(college$grad_150_value, probs=c(0.1,0.9), na.rm=TRUE) # 10th and 90th quantiles
summary(college$grad_150_value)

# more missingness
# is.na() generates TRUE/FALSE based on whether a field is NA
is.na(college$grad_150_value)

# TRUE/FALSE are stored as ones and zeros so we sum and average them.

# number of missing
sum(is.na(college$grad_150_value))
mean(is.na(college$grad_150_value)) # proportion missing

# which rows are missing? (ie, which rows are true?)
which(is.na(college$grad_150_value))

# view colleges with missing grad_150_value
college[which(is.na(college$grad_150_value)),"chronname"]
as.data.frame(college[which(is.na(college$grad_150_value)),"chronname"])

# The previous code is kind of messy;
# A preview of using the tidyverse with pipes
college %>% 
  filter(is.na(college$grad_150_value)) %>% 
  select(chronname) %>% 
  as.data.frame()

# All missing values in a data frame
# Again, TRUE/FALSE are stored as ones and zeros so we can sum and average them.

sum(is.na(college)) # number of missing values in college data
mean(is.na(college)) # percent of missing values in college data

# number of missing in each column
# colSums() sums all values in each column of a data frame
# colMeans() averages all values in each column of a data frame
colSums(is.na(college)) # number of missing in each column
colMeans(is.na(college)) # proportion of missing in each column
colMeans(is.na(college)) %>% round(3)

# can use TRUE/FALSE values with subsetting brackets;
# one rows with TRUE are retained;
# new data frame of colleges with missing endowment values
missendow <- college[is.na(college$endow_value),]

# View schools in Virginia with missing endowments using the subset function.
# basic syntax: subset(data, condition)
subset(missendow, missendow$state=="Virginia")

# YOUR TURN: In the gapminder data, 
# What's the first observation? The last?


# How many unique values does the variable "continent" have? How many observations are
# in each level?


# What are the mean and median of "lifeExp"?


# What are 33rd and 66th percentile values of "lifeExp"?


# Find (and print to the console) the rows for Greece.


# list objects ------------------------------------------------------------

# statistical and modeling output is often stored in a list object.

# a list is the most general type of storage object, storing data of different
# sizes and types.

# It's good to know how to navigate around and extract stuff out of a list.

list_ex <- list(a = 1:5, 
                b = c("yes", "no"), 
                c = c(TRUE, FALSE), 
                d = data.frame(x = 1:2, 
                               y = c(1.2, 4.3)))
list_ex

# The first element of a list is still a list when accessed with single brackets
list_ex[1]

# The first element of a list is whatever object it is when accessed with double
# brackets
list_ex[[1]]

# Can also access with $ notation, similar to using double brackets
list_ex$a
list_ex$d

# Use $ successively to access column of a data frame in a list
list_ex$d$x

# A more realistic example:
# Compare median SAT between the three types of schools using a boxplot
boxplot(med_sat_value ~ control, data = college, ylab = "median SAT")

# Creating a boxplot calculates summary stats that we can save:
bp <- boxplot(med_sat_value ~ control, data = college)

# bp is a list object
# see ?boxplot for details on what the list contains

# look inside: type bp$

# number of obs in each group
bp$n

# Boxplot stats
bp$stats

# The extreme upper whisker for "Public" universities
bp$stats[5,3]

# schools beyond the extreme upper whisker (ie, the outliers)
subset(college, med_sat_value > bp$stats[5,3] & control == "Public", 
       select = c(chronname, med_sat_value))


# Saving Data ------------------------------------------------------------

# R objects can be saved individually or collectively

# To save an individual object, use saveRDS() with file extension .Rds
# To read an Rds file, use readRDS()

# Quick demo...
# saveRDS()
saveRDS(missendow, file = "missendow.Rds")

# remove object
rm(missendow)

# readRDS()
missendow <- readRDS(file = "missendow.Rds")

# To save objects collectively, use save() with file extension .Rda
# To load an Rda file, use load()

# save objects for later use (we'll start with this object in part 2)
save(gm, college, missendow, file="data/introR1.Rda")

# clear your workspace, or click the broom icon in the environment pane
rm(list=ls())

# load Rda file
load("data/introR1.Rda")


