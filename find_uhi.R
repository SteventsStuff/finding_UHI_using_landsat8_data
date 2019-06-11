# import
library(raster)
library(sf)

# set up working dir
current_wd <- "D:/vova/diploma/LST/LST_using_R/main_script"

setwd(current_wd)

# load LST raster
lst <- raster("output/lst.tif")

# clip LST raster with city Dnipro border
dp <- st_read("area_of_interest/dnipro_utm.geojson")
dp_sp <- as(dp, "Spatial")
lst_msk <- mask(x = lst, mask = dp_sp)
lst_msk_cr <- crop(x = lst_msk, y = extent(dp_sp))

# show reslut
plot(lst_msk_cr)

#save result
writeRaster(lst_msk_cr, "output/lst_clipped_dp.tif", overwrite=TRUE)


# find UHI
lst_uhi <- lst_msk_cr
# get pixels values
lst_v <- getValues(lst_uhi)

uhi_th <- function(x) mean(x, na.rm = T) + 0.5*sd(x, na.rm = T)
(uhi_T <- uhi_th(lst_v))

# mask all area but UHI
lst_uhi[lst_uhi <= uhi_T] <- NA

# show result
plot(lst_uhi)

# save result
writeRaster(lst_uhi, "output/uhi.tif", overwrite=TRUE)


# Mark the must heat area of UHI
# Such extremes exist:
boxplot(lst_v)

# Mark only extremes LST values
qnt <- quantile(lst_v, probs=c(.25, .75), na.rm = T)
H <- 3 * IQR(lst_v, na.rm = T)

lst_ext <- lst_msk_cr
lst_ext[lst_ext <= (qnt[2] + H)] <- NA

plot(lst_ext)

# Divide the raster into fragments
# StackExchange: Remove clumps of pixels in R
# https://gis.stackexchange.com/questions/130993/remove-clumps-of-pixels-in-r
rc <- clump(lst_ext) 
freq(rc)
plot(rc)


# Vectorize extreme heat areas
pol <- rasterToPolygons(rc, dissolve = T)
pol$clumps <- as.integer(pol$clumps)

plot(pol)

# Get middle temprerature in heat area
mean_temp <- extract(lst_uhi, pol, fun=mean, na.rm=T, weights=T)
# Add temp into vector layer
pol$mean_temp <- as.vector(mean_temp)
# Add max temp into vector
max_temp <- extract(lst_uhi, pol, fun=max, na.rm=T)
pol$max_temp <- as.vector(max_temp)

# save shapefile with the most heat area
shapefile(pol, "area_of_interest/uhi/extrema_heats.shp", overwrite=T)
