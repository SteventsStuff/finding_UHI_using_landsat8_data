#import
library(raster)

# set up working dir
current_wd <- "D:/vova/diploma/LST/LST_using_R/main_script"

setwd(current_wd)

# load NDVI raster
ndvi <- raster("output/ndvi.tif")

# calc emissivity
emissiv <- ndvi
emissiv[ndvi < -0.185] <- 0.995
emissiv[(ndvi >= -0.185)&(ndvi < 0.157)] <- 0.985
emissiv[(ndvi >= 0.157)&(ndvi <= 0.727)] <- 1.089 + 0.047*log(ndvi[(ndvi >= 0.157)&(ndvi <= 0.727)])
emissiv[ndvi > 0.727] <- 0.990

# show emissivity
plot(emissiv)

# calc LST
BT <- raster("output/bt10_k.tif")

h <- 6.62607015e-34 # Planck's constant
c <- 299792458      # light speed, м/с
s <- 1.38064852e-23 # Boltzmann constant
rho <- h*c/s
lambda <- 10.8e-6   # average wavelength for range (10.60 – 11.19)e-6m

# LST in celsius
LST <- BT / (1 + lambda * BT/rho * log(emissiv)) - 273.15
# show result
plot(LST)

# save LST raster
writeRaster(LST, "ooutput/lst.tif", overwrite=TRUE)

# show diff between BT and LST
(dT <- LST - (BT - 273.15))
plot(dT)

# Where are the biggest mistakes made?
rel_temp_err <- abs(dT/LST)
rel_temp_err[rel_temp_err < 0.1] <- NA

# show result
plot(rel_temp_err)
