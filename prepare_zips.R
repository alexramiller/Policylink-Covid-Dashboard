library(dplyr)
library(tigris)
library(sf)
options(tigris_type = "sf")

## Loading CA Zip Code Areas (NOTE: This may take a while)
ca_zips <- zctas(state = "CA", cb = TRUE)
## Loading CA Counties and filtering to Bay Area
ca_counties <- counties(state = "CA", cb = TRUE)
bay_counties <- ca_counties %>% 
  filter(NAME %in% c("Alameda", "Contra Costa", "Marin", "Napa", "San Francisco", 
                     "San Mateo", "Santa Clara", "Solano", "Sonoma"))

## Saving Zip Code Areas in Bay Area counties
bay_zips <- st_join(ca_zips, bay_counties)
bay_zips %<>% filter(!is.na(COUNTYFP)) %>% select(ZIP = GEOID10, NAME)

write.csv(bay_zips %>% st_drop_geometry(), "bay_zips.csv", row.names = FALSE)
