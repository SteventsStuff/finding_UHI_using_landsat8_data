# import
library(sp)
library(raster)
library(sf)

# set up main dirs
current_wd <- "D:/vova/diploma/LST/LST_using_R/main_script"
downloaded_folder_name <- "downloaded_data"
scene_folder <- "LC08_L1TP_178026_20181018_20181031_01_T1_L1"
band_4_name <- "LC08_L1TP_178026_20181018_20181031_01_T1_B4.TIF"
band_5_name <- "LC08_L1TP_178026_20181018_20181031_01_T1_B5.TIF"

# set up values from metadata
REFLECTANCE_MULT_BAND <- 2.0000E-05
REFLECTANCE_ADD_BAND <- -0.100000
SUN_ELEVATION = 30.24171007

# set WD
setwd(current_wd)

# load bands
# 4 (red), 5 (NIR) - for NDVI calculation
red <- raster(paste(current_wd, downloaded_folder_name, scene_folder, band_4_name, sep="/"))
nir <- raster(paste(current_wd, downloaded_folder_name, scene_folder, band_5_name, sep="/"))

# clip raster using AOI geojson file
dp <- st_read("area_of_interest/dnipro_shape.geojson")
crs(red)
st_crs(dp)
dp <- st_transform(dp, proj4string(red))

# save borders in UTM projection (zone 36)
st_write(dp, "area_of_interest/dnipro_utm.geojson")
dp <- as(dp, "Spatial")

red <- crop(x = red, y = extent(dp))
nir <- crop(x = nir, y = extent(dp))

# Calc NDVI
# Calc TOA Rerlectance
toa_ref <- function(x){(x * REFLECTANCE_MULT_BAND + REFLECTANCE_ADD_BAND) / sin(SUN_ELEVATION * (pi /180))}

b4 <- calc(red, fun=toa_ref)
# for better results we need our NDVI to be in range [0-1]
b4[b4 < 0] <- 0
b4[b4 > 1] <- 1

b5 <- calc(nir, fun=toa_ref)
b5[b5 < 0] <- 0
b5[b5 > 1] <- 1

# NDVI formula
calc_ndvi <- function(nir,red) {(nir - red)/(nir + red)} 

# actual calculation
ndvi <- calc_ndvi(b5, b4)
# draw plot
plot(ndvi)

# Save result
writeRaster(ndvi, "output/ndvi.tif", overwrite=TRUE)
