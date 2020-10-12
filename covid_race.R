library(tidyr)
library(dplyr)
library(ggplot2)
library(curl)
#setwd("/Users/ajramiller/Dropbox/2020-2021/PolicyLink/COVID/")
setwd("/Users/ajramiller/Git/Policylink-Covid-Dashboard/")
#sf <- read.csv("COVID-19__Cases_Summarized_by_Race_and_Ethnicity.csv") %>%
sf <- read.csv(curl_download("https://data.sfgov.org/api/views/vqqm-nsqg/rows.csv", "sf_race.csv"), stringsAsFactors = FALSE) %>%
  mutate(Specimen.Collection.Date = as.Date(Specimen.Collection.Date))

sf_new <- sf %>%
  select(Specimen.Collection.Date, Race.Ethnicity, New.Confirmed.Cases) %>%
  group_by(Specimen.Collection.Date) %>%
  spread(Race.Ethnicity, New.Confirmed.Cases)

sf_cumulative <- sf %>%
  select(Specimen.Collection.Date, Race.Ethnicity, Cumulative.Confirmed.Cases) %>%
  group_by(Specimen.Collection.Date) %>%
  spread(Race.Ethnicity, Cumulative.Confirmed.Cases)

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