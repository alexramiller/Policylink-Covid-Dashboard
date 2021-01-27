suppressWarnings(suppressMessages(library(magrittr)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(curl)))
suppressWarnings(suppressMessages(library(readr)))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(xml2)))
suppressWarnings(suppressMessages(library(rvest)))

bay_zips <- read.csv("bay_zips.csv", stringsAsFactors = FALSE) %>%
  mutate(ZIP = as.character(ZIP))
alameda <- read.csv(curl_download("https://opendata.arcgis.com/datasets/5d6bf4760af64db48b6d053e7569a47b_0.csv", "alameda.csv"), stringsAsFactors = FALSE)
santa_clara <- read.csv(curl_download("https://data.sccgov.org/api/views/j2gj-bg6c/rows.csv?accessType=DOWNLOAD", "santa_clara.csv"), stringsAsFactors = FALSE)
sf <- read.csv(curl_download("https://data.sfgov.org/api/views/tpyr-dvnc/rows.csv?accessType=DOWNLOAD", "sf.csv"), stringsAsFactors = FALSE)
sonoma <- read_file(curl_download("https://socoemergency.org/emergency/novel-coronavirus/coronavirus-cases/", "sonoma.html"))
sonoma <- str_extract(sonoma, "(?s)Cases by Zip Code(.*?)Cases by Source")
sonoma <- as.data.frame(read_html(sonoma) %>% html_table(fill=TRUE)) %>%
  select(ZIP = Zip.Code, Cases = Total.Cases, Rate = Total.Case.Rate.per.100.000.Residents) %>%
  mutate(Cases = ifelse(Cases == "10 or less", 5, Cases),
         Cases = as.numeric(str_remove(Cases, ",")),
         Population = round(100000*Cases/Rate, 0))

if(!exists("alameda") & !exists("santa_clara") & !exists("sf") & !exists("sonoma")){
  stop("Data download failed. Try again later.")
}

alameda %<>% 
  mutate(Zip_Number = as.character(Zip_Number)) %>%
  select(ZIP = Zip_Number, Population, Cases, Rate = CaseRates)
santa_clara %<>% 
  mutate(zipcode = as.character(zipcode)) %>%
  select(ZIP = zipcode, Population, Cases, Rate)
sf %<>% 
  filter(area_type == "ZCTA") %>%
  mutate(id = as.character(id),
         Rate = 10*rate) %>%
  select(ZIP = id, Population = acs_population, Cases = count, Rate)
sonoma %<>% 
  mutate(ZIP = as.character(ZIP)) %>%
  select(ZIP, Population, Cases, Rate)


output <- bind_rows(alameda, santa_clara, sf, sonoma)
output <- bay_zips %>% 
  left_join(output) %>% 
  mutate(Population = ifelse(is.na(Population), -1, Population),
         Cases = ifelse(is.na(Cases), -1, Cases),
         Rate = ifelse(is.na(Rate), -1, Rate),
         Population_key = ifelse(Population < 0, "No Data", as.character(format(Population, big.mark = ","))),
         Cases_key = ifelse(Cases < 0, "No Data", as.character(format(round(Cases), big.mark = ","))),
         Rate_key = ifelse(Rate < 0, "No Data", as.character(format(round(Rate), big.mark = ","))))
  
write.csv(output, "covid_bay_counties.csv", row.names = FALSE)
