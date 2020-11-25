pwd
git pull
Rscript covid_download.R
Rscript covid_race.R
git add "covid_bay_counties.csv"
git add "sf_race_cumulative.csv"
git add "alameda_race_cumulative.csv"
git commit -m "Daily Update"
git push
