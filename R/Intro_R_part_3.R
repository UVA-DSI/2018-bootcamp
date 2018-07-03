# Introduction to R: combine and reshape data
# July 2018
# Clay Ford
# UVa Library Research Data Services

library(tidyverse)


# combining data sets -----------------------------------------------------

# Let's create some fake data to demonstrate binding

dat01 <- tibble(x = 1:5, y = 5:1)
dat01
dat02 <- tibble(x = 10:16, y = x/2)
dat02
dat03 <- tibble(z = runif(5))
dat03

# Base R: dat01 <- data.frame(x = 1:5, y = 5:1)

# row binding
# ie, stack data frames
bind_rows(dat01, dat02)
# Base R: rbind(dat01, dat02)

# When you supply a column name with the `.id` argument, a new
# column is created to link each row to its original data frame
bind_rows(dat01, dat02, .id = "id")
bind_rows("dat01" = dat01, "dat02" = dat02, .id = "id")


# column binding
# ie, set data frames side-by-side
bind_cols(dat01, dat03)
# Base R: cbind(dat01, dat03)

# Example: read in and combine multiple csv files
setwd("data/stocks")

# get file names using the list.files() function
files <- list.files()

# "apply" the read_csv() function to each file name using the map() function
# from the purrr package
stocks <- map(files, read_csv)
# stocks is a list of data frames

# name each list element using purrr function set_names()
# find/replace ".csv" with nothing using base R sub()
# fixed = TRUE means match literal string ".csv"
stocks <- set_names(stocks, sub(".csv", "", files, fixed = TRUE))

# combine into one data frame
stocks_df <- bind_rows(stocks, .id = "company")

# Base R:
# stocks <- lapply(files, read.csv)
# names(stocks) <- sub(".csv", "", files, fixed = TRUE)
# stocks_df <- do.call(rbind, stocks)
# stocks_df$company <- sub("\\.[0-9]*", "", rownames(stocks_df))


# merging data sets -------------------------------------------------------

# Let's walk through the examples presented in RStudio's dplyr cheat sheet.

a <- tibble(x1=c("A","B","C"), x2=1:3)
b <- tibble(x1=c("A","B","D"), x2=c(TRUE,FALSE,TRUE))
a;b

# mutating joins - create new data frames

# join matching rows from b to a, and keep all records in a
left_join(a, b, by="x1")

# base R equivalent
# merge(a, b, by="x1", all.x = TRUE) 

# join matching rows from a to b, and keep all records in b
right_join(a, b, by="x1")

# base R equivalent
# merge(a, b, by="x1", all.y = TRUE) 

# join data, retain only rows in both sets
inner_join(a, b, by="x1")

# base R equivalent
# merge(a, b, by="x1")

# join data, retain all values all rows (aka, outer join)
full_join(a, b, by="x1")

# base R equivalent
# merge(a, b, by="x1", all=TRUE) 

# filtering joins - returns a filtered data frame

# all rows in a that have a match in b
semi_join(a, b, by="x1")
# Base R equivalent:
# a[a$x1 %in% b$x1,] 

# all rows in a that do not have a match in b
anti_join(a, b, by="x1")
# Base R equivalent:
# a[!(a$x1 %in% b$x1),]

# set operations - comparing two data frames (notice these data frames have
# matching column names)

y <- tibble(x1=c("A","B","C"), x2=1:3)
z <- tibble(x1=c("B","C","D"), x2=2:4)
y
z

# rows that appear in both y and z
intersect(y, z)

# rows that appear in either or both y and z
union(y, z)

# rows that appear in y but not z
setdiff(y, z)

# rows that appear in z but not y
setdiff(z, y)



# tidy workspace
rm(a,b,y,z,dat01,dat02, dat03, files, stocks)


# Example: 3 Million Instacart Orders, Open Sourced
# https://www.instacart.com/datasets/grocery-shopping-2017

# "The Instacart Online Grocery Shopping Dataset 2017", Accessed from 
# https://www.instacart.com/datasets/grocery-shopping-2017 on 07-June-2017

# Well, not 3 million. I deleted some data so you didn't have to download 200 MB
# worth of files.

setwd("../instacart")

# order_products_train.csv: one row per product per order;
# tells us order of items added to cart, and if product was a re-order.
order_products <- read_csv("order_products_train.csv")

# orders_train.csv: one row per order;
# For each order tells us the user id, day of week of order, time of day, and
# days since last order.
orders <- read_csv("orders_train.csv")

# products.csv: one row per product with product, aisle and dept ids
# links product id to names of product
products <- read_csv("products.csv")

# aisles.csv: key to aisles
aisles <- read_csv("aisles.csv")

# departments.csv: key to departments
depts <- read_csv("departments.csv")

# We see that the order_products data frame contains one record per item per
# order, with the product identified by product_id.
head(order_products, n = 10)

# We see also that the orders data frame contains information about each order,
# such as day and hour of the order.
head(orders)

# We might want to join the order_products and orders data frame so we could
# learn more about, say, what products are purchased more often on certain days
# of the week. The key variable these two data frames have in common is
# order_id.

# Let's join orders with order_products, keeping all rows of order_products:
join01 <- left_join(order_products, orders, "order_id")
head(join01, n = 10)

# Notice join01 has the same number of rows as order_products since we did a
# left join.
all.equal(nrow(join01),nrow(order_products))

# Unfortunately join01 only has product IDs and not the name of the product.
# However the products data frame contains this information:
head(products)

# We could join the products data frame with join01 since they both contain the
# product_id field. Again we do a left join to keep all the records in join01.
join02 <- left_join(join01, products, "product_id")

# Now we can identify products for each order using their actual name
join02 %>% 
  select(order_id, product_id, product_name) %>% 
  head(n = 10)

# Brining in product names also brings in "aisle" and "department" info, but
# only as ID numbers.
join02 %>% 
  select(product_name, aisle_id, department_id) %>% 
  head(n = 10)

# It might be nice to know aisle and department names as well so we can see
# which aisles or departments are popular or not-so-popular. Again we can join
# the aisles and depts data frames by their respective IDs.
head(aisles)
head(depts)
join03 <- left_join(join02, aisles, "aisle_id")
join04 <- left_join(join03, depts, "department_id")

# And now we can see the items in the cart for an order along with information
# on department and aisle:
join04 %>% 
  select(order_id, product_name, aisle, department) %>% 
  head(n = 10)

# Instead of joining one data frame at a time, we can use pipes to combine the
# entire operation into one line of code:
all_orders <- left_join(order_products, orders, "order_id") %>%
  left_join(products, "product_id") %>% 
  left_join(aisles, "aisle_id") %>% 
  left_join(depts, "department_id")


# remove the join0X data frames
rm(list = paste0("join0",1:4))


# Reshaping data ----------------------------------------------------------

# The tidyverse package "tidyr" provides the gather and spread functions for
# reshaping data.

wide <- tibble(name=c("Clay","Garrett","Addison"),
               test1=c(78, 93, 90), 
               test2=c(87, 91, 97),
               test3=c(88, 99, 91))
wide

# make wide data long, aka "tidy"

# There are 4 columns, but only 3 variables: name, test, score

# gather(data, key, value, columns to gather (or not gather))

# "key" is the variable that will identify columns names that were "gathered", 
# "value" is what were previously under each column,
# "test1:test3" says "gather the test1, test2 and test3 columns"

long <- gather(wide, key = test, value = score, test1:test3)
long

# make long data wide
# spread(data, key, value)

# "key" indicates which column contains what are to be column headers
# "value" indicates what will go under each column
spread(long, key = test, value = score)

# reshaping data to "long" or "tidy" form is often used to facilitate creating
# plots in ggplot2.

# Let's reshape the stocks data frame so all prices are in one column. Notice
# the Open, High, Low and Close column names are actually a variable: price
# type.
head(stocks_df)
stocks_long <- gather(stocks_df, key = price_type, value = price, Open:Close)
head(stocks_long)

# Let's format Date column using lubridate function dmy()
library(lubridate)
stocks_long <- stocks_long %>% mutate(Date = dmy(Date))

# Graph high and low price for each stock
stocks_long %>% 
  filter(price_type %in% c("High","Low")) %>% 
  ggplot(aes(x = Date, y = price, color = price_type)) + 
  geom_line() +
  facet_wrap(~company, scales = "free_y")

# for open and close, fix x-axis labels, and legend title
stocks_long %>% 
  filter(price_type %in% c("Open","Close")) %>% 
  ggplot(aes(x = Date, y = price, color = price_type)) + 
  geom_line() +
  facet_wrap(~company, scales = "free_y") +
  scale_x_date(date_labels = "%b") +
  scale_color_discrete("Daily Range")

# %b is strptime code for abbreviated month name
# see ?strptime



# YOUR TURN ---------------------------------------------------------------


# Anscombe's quartet
# https://en.wikipedia.org/wiki/Anscombe%27s_quartet

# This data is loaded with R
anscombe
class(anscombe)

# Use what we've discussed (combining, merging, and reshaping) to wrangle the 
# data in such a way that you can recreate the plots using ggplot2. The fitted
# line can be added with geom_smooth(method = "lm", se = FALSE).

# The first few rows could look something like this:
#   group    y  x
# 1     1 8.04 10
# 2     1 6.95  8
# 3     1 7.58 13
# 4     1 8.81  9
# 5     1 8.33 11
# 6     1 9.96 14

# If you want, also verify the numerical summaries for all four groups: mean of
# x, mean of y, sd of x, sd of y, correlation of x and y.




# save data ---------------------------------------------------------------

save(stocks_long, all_orders, file = "../introR3.Rda")
