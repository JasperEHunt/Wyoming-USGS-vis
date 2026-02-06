library(terra)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

dir = "path/to/directory"

# Load raster of cottontail distribution
cotton <- rast(dir)

# Load in Wyoming data from rnaturalearthdata
states <- ne_states(country = "United States of America",
                    returnclass = "sf")
wyoming <- states[states$name == "Wyoming", ]

# Vectorise Wyoming data
wyoming <- vect(wyoming)

# Project all data to the same CRS (coordinate reference system)
target_crs <- "EPSG:4267"  # NAD27 (North American Datum 1927), legacy USGS coordinate system
wyoming <- project(wyoming, target_crs)
cotton_proj  <- project(cotton, target_crs, method = "near") # "Near" method chosen for categorical data

# Crop and mask cottontail data to Wyoming borders
cotton_wy <- crop(cotton_proj, wyoming)
cotton_wy <- mask(cotton_wy, wyoming)

# Produce plot of cottontail distribution in Wyoming
plot(cotton_wy[[1]],
     main = "Cottontail distribution (Hanser, 2011)",
     col = c("white", "darkgreen")
)
lines(wyoming, lwd = 2)