# import 
library(sf)
library(httr)
library(leaflet)

# set up working dir
current_WD <- "D:/vova/diploma/LST/LST_using_R/main_script"

setwd(current_WD)

# load shapefile of heat areas
hot_spot <- st_read("area_of_interest/uhi/extrema_heats.shp")

epsg4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
hot_spot <- st_transform(hot_spot, epsg4326)

# coords of area centers
hp <- st_coordinates(st_centroid(hot_spot))

obj_names <- vector(length=nrow(hp))

# get addresses with
# Nominatim API Reverse Geocoding
for (i in 1:nrow(hp)) {
  lon <- hp[i,1]
  lat <- hp[i,2]
  
  url <- paste0("http://nominatim.openstreetmap.org/reverse?format=json&lon=",lon,"&lat=",lat)
  rsp <- GET(url)
  obj <- content(rsp, as="parsed")
  
  print(obj$display_name)
  
  obj_names[i] <- obj$display_name
}

# add address to area's data
hot_spot$name <- obj_names

# show resultes on map
leaflet(hot_spot) %>% 
  addTiles() %>% 
  addPolygons() %>% 
  addMarkers(lng = hp[,1], lat = hp[,2], label = hot_spot$name)

