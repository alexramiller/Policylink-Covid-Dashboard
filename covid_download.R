suppressWarnings(suppressMessages(library(magrittr)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(curl)))

bay_zips <- read.csv("bayarea_zipcodes.csv", stringsAsFactors = FALSE) %>%
  select(ZIP)

alameda <- read.csv(curl_download("https://opendata.arcgis.com/datasets/5d6bf4760af64db48b6d053e7569a47b_0.csv", "alameda.csv"), stringsAsFactors = FALSE)
santa_clara <- read.csv(curl_download("https://data.sccgov.org/api/views/j2gj-bg6c/rows.csv?accessType=DOWNLOAD", "santa_clara.csv"), stringsAsFactors = FALSE)
sf <- read.csv(curl_download("https://data.sfgov.org/api/views/tpyr-dvnc/rows.csv?accessType=DOWNLOAD", "sf.csv"), stringsAsFactors = FALSE)

alameda %<>% 
  mutate(Zip_Number = as.character(Zip_Number)) %>%
  select(ZIP = Zip_Number, Population, Cases, Rate = CaseRates)
santa_clara %<>% 
  mutate(zipcode = as.character(zipcode)) %>%
  select(ZIP = zipcode, Population, Cases, Rate)
sf %<>% 
  filter(area_type == "ZCTA") %>%
  mutate(id = as.character(id)) %>%
  select(ZIP = id, Population = acs_population, Cases = count, Rate = rate)

output <- bind_rows(alameda, santa_clara, sf)
output <- bay_zips %>% left_join(output)

write.csv(output, "covid_bay_counties.csv", row.names = FALSE)
