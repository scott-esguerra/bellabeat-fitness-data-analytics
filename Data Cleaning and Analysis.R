---
title: "Bellabeat Analysis R Notebook"
Author: Scott Esguerra
Date: "2023-02-07"
output:
  html_document:
    df_print: paged
---

# Data Cleaning

### ABOUT THE DATASET

This data is a third-party dataset that is publicly available on Kaggle: FitBit Fitness Tracker Data stored in 18 separate csv files. The data was gathered from respondents to a Amazon Mechanical Turk survey between March 12, 2018 and May 12, 2016. Personal tracker data on sleep, heart-rate, and physical activity was collected from 30 consenting eligible Fitbit users.

The dataset have some limitations: it is quite old so it may not give relavant and modern trends, it also has a small sample size and may subject to response bias during data collection.

I selected dailyActivity_merged.csv and weightLogInfo.csv for this analysis.

### PREPARE THE ENVIROMENT

```{r}
# Load relevant pakages
library(tidyverse)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
```

### IMPORT THE DATASET

```{r}
#Setting up data path
getwd()
setwd("C:/Users/Alexis/Desktop/Scott/Case Studies/Case Study 2/Fitabase Data 4.12.16-5.12.16")

daily_activity <- read.csv("dailyActivity_merged.csv")
weight_log <- read.csv("weightLogInfo_merged.csv")
```

### DATA CLEANING

```{r}
# Discover amount of rows and columns and type of data 
glimpse(daily_activity)
```
```{r}
glimpse(weight_log)
```
```{r}
# Check for null values 
sum(is.na(daily_activity))
```
```{r}
sum(is.na(weight_log))
```
```{r}
sum(is.na(weight_log$Fat))
```
Noted that all null for weight_log is in Fat column
```{r}
# Preview IDs for each data set
n_distinct(daily_activity$Id)
```

```{r}
# Check why there are over 30 participants, noted that none appear to be typos 
unique(daily_activity$Id)
```
```{r}
n_distinct(weight_log$Id)
```
There are less participants who provided weight 

```{r}
# Check for duplicates and remove duplicate rows 
sum(duplicated(daily_activity))
```
```{r}
sum(duplicated(weight_log))
```

From the above observation, we noted the following:

The daily_activity data set has the most data, with 940 rows and 18 columns. The weight_log has 67 rows and 8 columns.

Dates are listed as character type variables not date type for all data sets.

The weight_log data set is the only one containing NA values, all of which reside in the Fat column.

There are 33 unique id numbers listed in the daily_activity data set, although the data source background claims only 30 participants took part in the survey. Some of these could be entered incorrectly, or a participant could have multiple accounts with multiple id numbers.

Not as many participants recorded data for the and weight_log data set, with only 8 unique id numbers listed in weight_log.

# Analyzing the Data

### DATA MANIPULATION

```{r}
# Add relevant columns to daily_activity and drop old columns 

daily_activity_update <- daily_activity %>% 
  mutate(activity_date = mdy(daily_activity$ActivityDate)) %>% 
  mutate(weekday = wday(activity_date)) %>% 
  mutate(total_active_minutes = VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) %>% 
  mutate(total_active_hours = round(total_active_minutes/60, 2)) %>% 
  mutate(day_of_week = weekdays(activity_date)) %>% 
  select(-2)

## Rename Columns in daily_activity to be uniform 
daily_activity_renamed <- rename(daily_activity_update, id = Id, 
total_steps = TotalSteps, 
total_distance = TotalDistance, 
tracker_distance = TrackerDistance, 
active_distance_logged = LoggedActivitiesDistance, 
active_distance_very = VeryActiveDistance, 
active_distance_moderate = ModeratelyActiveDistance, 
active_distance_light = LightActiveDistance, 
active_distance_sedentary = SedentaryActiveDistance, 
active_minutes_very = VeryActiveMinutes, 
active_minutes_fairly = FairlyActiveMinutes, 
active_minutes_lightly = LightlyActiveMinutes,
minutes_sedentary = SedentaryMinutes,
calories= Calories)
```

```{r}
daily_activity_final <- daily_activity_renamed %>% arrange(id)
glimpse(daily_activity_final)
```
```{r}
## Add relevant columns to weight_log in correct formats 

weight_log_update <- weight_log %>% 
  mutate(date1 = mdy_hms(weight_log$Date)) %>% 
  mutate(date2 = format(date1, "%m/%d/%y")) %>% 
  mutate(date = mdy(date2)) %>% 
  mutate(manual_report = as.logical(weight_log$IsManualReport))

## Rename and drop old columns in weight_log 

weight_log_final <- weight_log_update %>% 
  rename(id = Id,
         weight_kg = WeightKg, 
         weight_lbs = WeightPounds, 
         fat = Fat, 
         bmi = BMI, 
         log_id = LogId) %>% 
  select(-2,-7,-9, -10) %>%
  arrange(id)
```

```{r}
glimpse(weight_log_final)
```

The following data manipulations were performed:

daily_activity:

1. Convert ActivityDate to date data type and store as a new column activity_date

2. Create a new column weekday to show the day of the week for each recorded date

3. Create a new column total_active_minutes as a calculation of the sum of VeryActiveMinutes, FairlyActiveMinutes, and LightlyActiveMinutes

4. Create a new column total_active_hours by dividing total_active_minutes by 60

5. Drop the ActivityDate column

6. Rename columns to be similar format to ease readability

7. Store final data set as daily_activity_final

weight_log:

1. Convert Date column to date data type and store as date

2. Convert IsManualReport column to logical data type and store as manual_report

3. Rename columns to be similar format and drop irrelevant columns

4. Store final data set as weight_log_final

### DATA CALCULATIONS

Pulling the statistics of data sets for analysis:

```{r}
daily_activity_final %>% summary()
```
```{r}
daily_activity_final %>% summarize_all(sd)
```
```{r}
weight_log_final %>% summary()
```
```{r}
weight_log_final %>% summarize_all(sd)
```
The summary() function provides min, 1st quartile, median, mean, 3rd quartile, and max data for each numerical row.

### INTERPRET FINDINGS

Key findings:

On average, users logged 7,638 total steps, with a low of 0 and a high of 36,019, which is a very large range.
The average BMI of the 8 users who provided data was 25.19, which is considered overweight according to the CDC BMI chart, yet still under the average American adult BMI of 26.6.

```{r}
# Save into a csv file
write.csv(daily_activity_final, file = 'C:/Users/Alexis/Desktop/Scott/Case Studies/Case Study 2/daily_activity_modified.csv')
write.csv(weight_log_final, file = 'C:/Users/Alexis/Desktop/Scott/Case Studies/Case Study 2/weight_log_modified.csv')
```
