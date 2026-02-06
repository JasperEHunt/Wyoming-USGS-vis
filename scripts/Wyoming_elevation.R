library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(elevatr)
library(terra)

# Load in Wyoming data from rnaturalearthdata
states <- ne_states(country = "United States of America",
                    returnclass = "sf")
wyoming <- states[states$name == "Wyoming", ]

# Plot elevations
d <- get_elev_raster(locations = wyoming, z = 9, clip = "locations")
terra::plot(rast(d), plg = list(title = "Elevation (m)"))