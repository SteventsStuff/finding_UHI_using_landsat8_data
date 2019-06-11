# required libs
#devtools::install_github("16EAGLE/getSpatialData")
#install.packages("rgdal")
#install.packages("sp")
#install.packages("devtools")

# import
library(getSpatialData) 
library(sf)

# set up basic dirs
current_WD <- "D:/vova/diploma/LST/LST_using_R/main_script"
dir_for_download <- "downloaded_data"
# set up date range
date_start <- "2018-06-01"
date_end <- "2019-06-10"

# set current working dir
setwd(current_WD)

# using http://geojson.io/ for creating rectangle around the city Dnipro
# (POLYGON.shp)
aoi_data <- st_read("area_of_interest/for_scene_search/POLYGON.shp")
aoi <- aoi_data$geometry
set_aoi(aoi)

# login USGS profile
login_USGS(username = "username", password = "password")
# we are looking for "LANDSAT_8_C1" products
(product_names <- getLandsat_names()) 

# get all available data throught request 
time_range <-  c(date_start, date_end)
satellite <- "LANDSAT_8_C1"                 
response <- getLandsat_query(time_range = time_range, name = satellite)

# set satellite ROW and PATH of interest
# using https://search.remotepixel.ca for finding row and path
row  <- 26
path <- 178
# select data of interest, also searching for scene with cloud cover
# less than 20%
sorted_data <- response[
  (response$WRSRow==row)&(response$WRSPath==path)&(response$SceneCloudCover<20),
]
# get scene preview
getLandsat_preview(sorted_data[3,])
(chosen_scene <- sorted_data[3,]$levels_available)

# download scene
files <- getLandsat_data(
  records = chosen_scene,
  level = "l1",
  source = "auto", 
  dir_out = dir_for_download
  )
