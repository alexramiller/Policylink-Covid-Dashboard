library(tidyr)
library(dplyr)
library(ggplot2)
library(curl)
library(zoo)
#setwd("/Users/ajramiller/Dropbox/2020-2021/PolicyLink/COVID/")
setwd("/Users/ajramiller/Git/Policylink-Covid-Dashboard/")
#sf <- read.csv("COVID-19__Cases_Summarized_by_Race_and_Ethnicity.csv") %>%
sf <- read.csv(curl_download("https://data.sfgov.org/api/views/vqqm-nsqg/rows.csv", "sf_race.csv"), stringsAsFactors = FALSE) %>%
  mutate(Specimen.Collection.Date = as.Date(Specimen.Collection.Date))

sf_new <- sf %>%
  select(Specimen.Collection.Date, Race.Ethnicity, New.Confirmed.Cases) %>%
  mutate(Race.Ethnicity = ifelse(Race.Ethnicity %in% c("Other", "Unknown", "Multi-racial", "Native American", "Native Hawaiian or Other Pacific Islander"), "Other", Race.Ethnicity)) %>%
  group_by(Specimen.Collection.Date, Race.Ethnicity) %>%
  summarize(New.Confirmed.Cases = sum(New.Confirmed.Cases, na.rm = TRUE)) %>%
  group_by(Specimen.Collection.Date) %>%
  spread(Race.Ethnicity, New.Confirmed.Cases) %>%
  ungroup() %>%
  mutate_at(vars(Asian:White), function(x) rollmean(x, 7, na.pad = TRUE))

sf_cumulative <- sf %>%
  select(Specimen.Collection.Date, Race.Ethnicity, Cumulative.Confirmed.Cases) %>%
  mutate(Race.Ethnicity = ifelse(Race.Ethnicity %in% c("Other", "Unknown", "Multi-racial", "Native American", "Native Hawaiian or Other Pacific Islander"), "Other", Race.Ethnicity)) %>%
  group_by(Specimen.Collection.Date, Race.Ethnicity) %>%
  summarize(Cumulative.Confirmed.Cases = sum(Cumulative.Confirmed.Cases, na.rm = TRUE)) %>%
  group_by(Specimen.Collection.Date) %>%
  spread(Race.Ethnicity, Cumulative.Confirmed.Cases)

write.csv(sf_new, "sf_race_new.csv", row.names = FALSE)
write.csv(sf_cumulative, "sf_race_cumulative.csv", row.names = FALSE)

#ggplot(data = sf) + geom_line(aes(x = Specimen.Collection.Date, 
#                                    y = Cumulative.Confirmed.Cases, 
#                                    group = Race.Ethnicity,
#                                    color = Race.Ethnicity))
#ggplot(data = sf) +
#  geom_point(aes(x = Specimen.Collection.Date, 
#                  y = New.Confirmed.Cases, 
#                  group = Race.Ethnicity,
#                  color = Race.Ethnicity),
#             size = 0.5, alpha = 0.5) +
#  geom_smooth(aes(x = Specimen.Collection.Date, 
#                                    y = New.Confirmed.Cases, 
#                                    group = Race.Ethnicity,
#                                    color = Race.Ethnicity))