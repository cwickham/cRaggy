#' Adapted from: https://github.com/smithjd/cRaggy-example/blob/master/minimal-cRaggy.R
#' Minimal cRaggy example
#' John David Smith - john.smith@learningalliances.net - Twitter / github: smithjd
#'
#' Edits by Charotte Wickham
#' Generates data/public-trips.csv and data/public-trips.rds

library(tidyverse)
library(fs)
library(here)

url <- "https://s3.amazonaws.com/biketown-tripdata-public/BiketownPublicTripData201804.zip"

if (!dir_exists("PublicTripData/")){
  download.file(url, dest = "dataset.zip", mode = "wb")
  unzip("dataset.zip", exdir = "./")
}

# What's in the Quarterly Data?
trip_files <- dir_ls("PublicTripData/", regexp = ".*\\.csv")

public_trip_data <- trip_files %>%
  map_dfr(read_csv,
    col_types = cols(
      Duration = col_character(),
      StartDate = col_character(),
      StartTime = col_character(),
      EndDate = col_character(),
      EndTime = col_character()))

# Parse date times ---------------------------------------------------------
public_trip_data <- public_trip_data %>%
  mutate(
    start = lubridate::mdy_hm(str_c(StartDate, StartTime, sep = " "),
      tz = "America/Los_Angeles"),
    end = lubridate::mdy_hm(str_c(EndDate, EndTime, sep = " "),
      tz = "America/Los_Angeles"))

# These crazy dates are really crazy!
public_trip_data %>%
  select(EndDate, end) %>%
  filter(lubridate::mdy(EndDate) > as.Date("2018-05-01"))

public_trip_data %>%
  select(EndDate, end) %>%
  filter(lubridate::mdy(EndDate) < as.Date("2016-07-01"))

outside_range <- function(x, lower, upper){
  x[x < lower] <- NA
  x[x > upper] <- NA
  x
}

# Make missing for now
public_trip_data <- public_trip_data %>%
  mutate(end = outside_range(end,
    lower = as.Date("2016-07-01"), upper = as.Date("2018-05-01")))

# Save for later ----------------------------------------------------------
usethis::use_directory("data")

public_trip_data %>%
  write_csv(here(path("data", "public-trips.csv")))

public_trip_data %>%
  write_rds(here(path("data", "public-trips.rds")))


# Cleanup -----------------------------------------------------------------

if (file_exists("dataset.zip")){
  file_delete("dataset.zip")
}


