#import
library(raster)
library(tmap)

# set up working dir
current_wd <- "D:/vova/diploma/LST/LST_using_R/main_script"

setwd(current_wd)

# load raster
lst <- raster("output/uhi.tif")

# build isolines (SpatialLinesDataFrame) in raster island
lst_l <- rasterToContour(lst, nlevels = 5)

# set up color palette
my.palette = sort(heat.colors(7), decreasing = T)

# Activate interactive view mode 
current.mode <- tmap_mode("view")

# show map
tm_shape(lst) + 
  tm_raster(palette = my.palette, title = "LST, \u00B0 C") + 
  tm_shape(lst_l) + tm_lines()
