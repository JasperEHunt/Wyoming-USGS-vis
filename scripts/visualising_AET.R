# Load libraries
library(sf)
library(terra)
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyr)
library(ggplot2)
library(gganimate)

# Define working directory
dir = "path/to/directory/"

# Get all .tif file names, including full paths
years <- list.files(path = paste(dir, "extracted", sep=""), pattern = "\\.tif$", 
                    full.names = TRUE)
# Extract years from file names
years_vec <- gsub(".*(\\d{4}).tif$", "\\1", basename(years))
years_vec <- as.integer(years_vec)

# Get Wyoming coords from rnaturalearth
states <- ne_states(country = "United States of America",
                    returnclass = "sf")
wyoming <- states[states$name == "Wyoming", ]
wyoming <- vect(wyoming)
# Convert to same CRS as AET data
wyoming <- project(wyoming, "EPSG:4269")

# Rasterise, crop and mask data to Wyoming only
r_wy <- mask(crop(rast(years), wyoming), wyoming)

# Assign years as SpatRaster layer names
names(r_wy) <- years_vec

# Convert raster to dataframe for plotting
r_df <- as.data.frame(r_wy, xy = TRUE, na.rm = FALSE)

# Pivot from wide df to long
r_df <- pivot_longer(
  r_df,
  cols = -c(x, y),
  names_to = "year",
  values_to = "value"
)
r_df$year <- as.integer(r_df$year)

# Plot one frame as a sanity check
ggplot(
  subset(r_df, year == min(year))
) +
  geom_raster(aes(x = x, y = y, fill = value)) +
  coord_equal()

# Plot animation
p <- ggplot(r_df) +
  geom_raster(aes(x = x, y = y, fill = value)) +
  geom_sf(data = st_as_sf(wyoming), fill = NA, color = "black", linewidth = 0.5) +
  coord_sf(crs = st_crs(4269)) +
  scale_fill_viridis_c(
    option = "mako",
    limits = range(r_df$value, na.rm = TRUE),
    na.value = "transparent"
  ) +
  labs(
    title = "Annual AET in Wyoming",
    subtitle = "Year: {frame_time}",
    fill = "AET"
  ) +
  theme_minimal() +
  transition_time(year) +
  ease_aes("linear")

# Render animation
animate(
  p,
  nframes = length(years_vec),
  fps = 1,
  width = 800,
  height = 600,
  renderer = file_renderer(
    dir = paste(dir, "png_frames", sep=""), prefix = "AET_Wyoming_", 
    overwrite = TRUE
  )
)
