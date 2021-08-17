# UMD Tutorial here 
# https://gisumd.github.io/COVID-19-API-Documentation/docs/tutorials/get_r.html

# The code allows us to generate the graphs for different countries for one indicator at a time 

# This package will automatically install the packages and then load it
library(pacman)

# load packages
pacman::p_load(tidyverse, httr, jsonlite, dplyr, ggplot2)

# Input indicator - only 1 at a time
# choose here: https://gisumd.github.io/COVID-19-API-Documentation/docs/indicators/indicators.html 
indicator <- "vaccine_acpt"
  
# input country name/s - can be multiple
countries <- c("Philippines", "Thailand", "Singapore", "Malaysia", "Vietnam", "Indonesia")
  
# input dates - must be in this format
dates <- "20210501-20210630"

# type = smoothed or daily 
type <- "daily"

# loop through the countries 
for (country in countries){
  # url
  path <- paste0("https://covidmap.umd.edu/api/resources?indicator=", indicator, "&type=",type, "&country=", country, "&daterange=", dates)
  # request data from api
  request <- GET(url = path)
  # make sure the content is encoded with 'UTF-8'
  response <- content(request, as = "text", encoding = "UTF-8")
  # now we have a dataframe for use!
  assign(paste0(indicator, "_", country), fromJSON(response, flatten = TRUE) %>% data.frame())
}

# this will create a new dataframe called indicator_all that will bind all the rows from the countries 
assign(paste0(indicator, "_", "all"), bind_rows(mget(ls(pattern = indicator))))

vaccine_acpt_all$date <- as.Date(vaccine_acpt_all$data.survey_date, "%Y%m%d")

# color palette: 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

acceptance <- ggplot(vaccine_acpt_all, aes(x = date, y = data.percent_vu, group = data.country, color = data.country)) + 
  geom_line(size = 0.8) + 
  labs(title = "Percentage of respondents who answered that have \n reported yes to definitely or probably \n choosing to get vaccinated",
       x = "Survey Date", 
       y = "Percentage of respondents",
       color = "Country") + 
  theme_classic() +
  scale_x_date(breaks = as.Date(c("2021-05-01", "2021-05-15", "2021-05-30", "2021-06-15"))) + 
  theme(axis.text.x=element_text(angle=45, hjust=1)) + 
  # scale_color_brewer(palette="Set1") + 
  scale_colour_manual(values=cbPalette) + 
  theme(plot.title = element_text(color = "black", size = 8, face = "bold", hjust = 0.5))
acceptance 

