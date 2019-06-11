# import
library(httr)
library(geojsonio)
library(sf)
library(leaflet)

# set up working WD
current_WD <- "D:/vova/diploma/LST/LST_using_R/main_script"

setwd(current_WD)

# make request to nominatim.openstreetmap.org
response <- GET("https://nominatim.openstreetmap.org/search.php?q=Днепр+Днепровский+городской+совет+Днепропетровская+область&polygon_geojson=1&limit=1&format=json")
# parse response
parsed_resp <- content(response, as="parsed")
dnipro_shape <- as.json(parsed_resp[[1]]$geojson)
# write geojson
geojson_write(dnipro_shape, file="area_of_interest/dnipro_shape.geojson")

# load dnipro_shape.geojson
dp_points <- st_read("area_of_interest/dnipro_shape.geojson")
map <- leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = dp_points, weight=2, color = "red")

# show map
map
