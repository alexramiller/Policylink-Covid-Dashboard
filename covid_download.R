suppressWarnings(suppressMessages(library(magrittr)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(curl)))

alameda <- read.csv(curl_download("https://opendata.arcgis.com/datasets/5d6bf4760af64db48b6d053e7569a47b_0.csv", "alameda.csv"))
santa_clara <- read.csv(curl_download("https://data.sccgov.org/api/views/j2gj-bg6c/rows.csv?accessType=DOWNLOAD", "santa_clara.csv"))
sf <- read.csv(curl_download("https://data.sfgov.org/api/views/tpyr-dvnc/rows.csv?accessType=DOWNLOAD", "sf.csv"))

alameda %<>% 
  select(ZIP = Zip_Number, Population, Cases, Rate = CaseRates)
santa_clara %<>% 
  select(ZIP = zipcode, Population, Cases, Rate)
sf %<>% 
  filter(area_type == "ZCTA") %>%
  mutate(ZIP = as.numeric(id)) %>%
  select(ZIP, Population = acs_population, Cases = count, Rate = rate)

output <- bind_rows(alameda, santa_clara, sf)

write.csv(output, "covid_bay_counties.csv", row.names = FALSE)
