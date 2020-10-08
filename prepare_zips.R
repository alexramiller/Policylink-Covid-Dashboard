library(tidyr)
library(dplyr)
library(tigris)
library(tidycensus)
library(sf)
library(yaml)
options(tigris_type = "sf")
rm(list = ls())

census_api_key(read_yaml("census.yaml"))

## Loading Zip Code Data (NOTE: This may take a while)
ca_zips <- left_join(
  zctas(state = "CA", cb = TRUE) %>%
    select(ZIP = GEOID10),
  get_acs(geography = "zcta",
                variables = c("B03002_001", "B03002_003", "B03002_004", "B03002_005", 
                              "B03002_006", "B03002_007", "B03002_008", "B03002_009",
                              "B03002_012"),
                year = 2018,
                geometry = FALSE) %>%
  select(-NAME, -moe) %>%
  group_by(GEOID) %>%
  spread(variable, estimate) %>%
  mutate(Total = B03002_001,
         White = B03002_003/B03002_001,
         Black = B03002_004/B03002_001,
         Asian = B03002_006/B03002_001,
         Latinx = B03002_012/B03002_001,
         Other = (B03002_005 + B03002_007 + B03002_008 + B03002_009)/B03002_001) %>%
  select(ZIP = GEOID, Total, White, Black, Asian, Latinx, Other))
## Loading CA Counties and filtering to Bay Area
ca_counties <- counties(state = "CA", cb = TRUE)
bay_counties <- ca_counties %>% 
  filter(NAME %in% c("Alameda", "Contra Costa", "Marin", "Napa", "San Francisco", 
                     "San Mateo", "Santa Clara", "Solano", "Sonoma"))

## Saving Zip Code Areas in Bay Area counties
bay_zips <- st_join(ca_zips, bay_counties, left = TRUE, largest = TRUE)
bay_zips %<>% 
  filter(!is.na(COUNTYFP)) %>% 
  select(ZIP, NAME, Total, White, Black, Asian, Latinx, Other) %>%
  mutate(White_key = paste0(round(100*White, 2), "%"),
         Black_key = paste0(round(100*Black, 2), "%"),
         Asian_key = paste0(round(100*Asian, 2), "%"),
         Latinx_key = paste0(round(100*Latinx, 2), "%"),
         Other_key = paste0(round(100*Other, 2), "%"))
         

write.csv(bay_zips %>% st_drop_geometry(), "bay_zips.csv", row.names = FALSE)
