# import
library(sp)
library(raster)
library(sf)

# set up main dirs
current_wd <- "D:/vova/diploma/LST/LST_using_R/main_script"
downloaded_folder_name <- "downloaded_data"
scene_folder <- "LC08_L1TP_178026_20181018_20181031_01_T1_L1"
band_10_name <- "LC08_L1TP_178026_20181018_20181031_01_T1_B10.TIF"

# values from metadata
RADIANCE_MULT_BAND_10 <- 3.3420E-04
RADIANCE_ADD_BAND_10 <- 0.10000
K1_CONSTANT_BAND_10 <- 774.8853
K2_CONSTANT_BAND_10 <- 1321.0789

# set WD
setwd(current_wd)

# load band
band_10 <- raster(paste(current_wd, downloaded_folder_name, scene_folder, band_10_name, sep="/"))

# clip band
dp <- st_read("area_of_interest/dnipro_utm.geojson")
dp_loaded <- as(dp, "Spatial")
band_10 <- crop(x = band_10, y = extent(dp_loaded))

# calc brightness  temperature

# get TOA Radiance on DN:
toa_band10 <- calc(band_10, fun=function(x){RADIANCE_MULT_BAND_10 * x + RADIANCE_ADD_BAND_10})

# calc BT in kelvin for band 10
bt10 <- calc(toa_band10, fun=function(x){K2_CONSTANT_BAND_10/log(K1_CONSTANT_BAND_10/x + 1)})
# show result
plot(bt10)

# save result
writeRaster(bt10, "output/bt10_k.tif", overwrite=TRUE)

