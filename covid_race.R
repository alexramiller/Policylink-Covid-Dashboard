library(tidyr)
library(dplyr)
library(ggplot2)
library(curl)
library(zoo)
#setwd("/Users/ajramiller/Dropbox/2020-2021/PolicyLink/COVID/")
#setwd("/Users/ajramiller/Git/Policylink-Covid-Dashboard/")
#sf <- read.csv("COVID-19__Cases_Summarized_by_Race_and_Ethnicity.csv") %>%
sf <- read.csv(curl_download("https://data.sfgov.org/api/views/vqqm-nsqg/rows.csv", "sf_race.csv"), stringsAsFactors = FALSE) %>%
  mutate(Specimen.Collection.Date = as.Date(Specimen.Collection.Date))

sf_cumulative <- sf %>%
  select(Specimen.Collection.Date, Race.Ethnicity, Cumulative.Confirmed.Cases) %>%
  mutate(Race.Ethnicity = ifelse(Race.Ethnicity %in% c("Other", "Unknown", "Multi-racial"), "Other", Race.Ethnicity)) %>%
  group_by(Specimen.Collection.Date, Race.Ethnicity) %>%
  summarize(Cumulative.Confirmed.Cases = sum(Cumulative.Confirmed.Cases, na.rm = TRUE)) %>%
  group_by(Specimen.Collection.Date) %>%
  spread(Race.Ethnicity, Cumulative.Confirmed.Cases) %>%
  mutate(`Asian/Pacific Islander` = ifelse(!is.na(Asian) | !is.na(`Native Hawaiian or Other Pacific Islander`),
                                           ifelse(is.na(Asian), 0, Asian) + ifelse(is.na(`Native Hawaiian or Other Pacific Islander`), 0, `Native Hawaiian or Other Pacific Islander`), NA)) %>%
  rename(Black = `Black or African American`, `Hispanic or Latino/a` = `Hispanic or Latino/a, all races`) %>%
  select(-Asian, -`Native Hawaiian or Other Pacific Islander`)

write.csv(sf_cumulative, "sf_race_cumulative.csv", row.names = FALSE)

alameda <- read.csv(curl_download("https://opendata.arcgis.com/datasets/5d6bf4760af64db48b6d053e7569a47b_6.csv", "alameda_race.csv"), stringsAsFactors = FALSE) %>%
  mutate(Week_Ending = as.Date(Week_Ending, format = "%Y/%m/%d"))

alameda_cumulative <- alameda %>%
  filter(Measure == "Cases") %>%
  select(Week_Ending, Zip, White, Black = AfAm_Black, `Hispanic or Latino/a` = Hisp_Lat, Asian, PacIsl, `Native American` = NatAmer, Multirace, Other_Unknown_Race) %>%
  mutate_at(vars(White:Other_Unknown_Race), function(x) ifelse(x == "<10", 1, x)) %>%
  mutate_at(vars(White:Other_Unknown_Race), as.numeric) %>%
  mutate(Other_Unknown_Race = ifelse(is.na(Other_Unknown_Race), 0, Other_Unknown_Race)) %>%
  mutate(`Asian/Pacific Islander` = Asian + PacIsl,
         Other = Multirace + Other_Unknown_Race) %>%
  group_by(Week_Ending) %>% summarize_at(c("Asian/Pacific Islander", "Black", "Hispanic or Latino/a", "Native American", "White", "Other"), sum) %>%
  mutate_all(function(x) ifelse(x == 0, NA, x))
  
write.csv(alameda_cumulative, "alameda_race_cumulative.csv", row.names = FALSE)

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