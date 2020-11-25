library(tidyr)
library(dplyr)
library(tigris)
library(tidycensus)
library(sf)
library(yaml)
options(tigris_type = "sf")
rm(list = ls())

setwd("~/Git/PolicyLink-Covid-Dashboard")

census_api_key(read_yaml("~/census.yaml"))

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
         White = 100*(B03002_003/B03002_001),
         Black = 100*(B03002_004/B03002_001),
         Asian = 100*(B03002_006/B03002_001),
         Latinx = 100*(B03002_012/B03002_001),
         Other = 100*((B03002_005 + B03002_007 + B03002_008 + B03002_009)/B03002_001)) %>%
  select(ZIP = GEOID, Total, White, Black, Asian, Latinx, Other))
## Loading CA Counties and filtering to Bay Area
ca_counties <- counties(state = "CA", cb = TRUE)

## Saving Zip Code Areas in Bay Area counties
bay_zips <- st_join(ca_zips, ca_counties, left = TRUE, largest = TRUE) %>% 
  filter(NAME %in% c("Alameda", "Contra Costa", "Marin", "Napa", "San Francisco", "San Mateo", "Santa Clara", "Solano", "Sonoma"))
bay_zips %<>% 
  filter(!is.na(COUNTYFP)) %>% 
  select(ZIP, NAME, Total, White, Black, Asian, Latinx, Other) %>%
  mutate(White_key = paste0(round(White, 2), "%"),
         Black_key = paste0(round(Black, 2), "%"),
         Asian_key = paste0(round(Asian, 2), "%"),
         Latinx_key = paste0(round(Latinx, 2), "%"),
         Other_key = paste0(round(Other, 2), "%"))
         

write.csv(bay_zips %>% st_drop_geometry(), "bay_zips.csv", row.names = FALSE)
st_write(bay_zips %>% st_transform(4326), "bay_zips.geojson", driver = "GeoJSON", delete_dsn = TRUE)
