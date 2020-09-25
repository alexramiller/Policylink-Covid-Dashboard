# Policylink-Covid-Dashboard

This repository permits the download of COVID count/rate data from county open data sites and the upload of that data to a Datawrapper application. This process is currently operable for Alameda, San Francisco, and Santa Clara counties.

In order to make this process run regularly:
- Clone this repository
- Set up an auatomatic process via Automatic Task Scheduler (Windows) / Automator (Mac) that runs `covid_update.bash` at a specified interval

For more information on Datawrapper application, see:
- https://academy.datawrapper.de/article/60-external-data-sources
- https://academy.datawrapper.de/article/236-how-to-create-a-live-updating-symbol-map-or-choropleth-map
