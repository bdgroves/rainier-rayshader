library(elevatr)
library(raster)
library(rayshader)
library(sf)

# Mt. Rainier National Park approximate bounding box
# Slightly padded for contexti
rainier_bbox <- data.frame(
  x = c(-122.00, -121.00),
  y = c(46.65,    47.00)
)

prj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# Fetch elevation - zoom 10 is a good balance of detail vs. size
# Increase to 11 or 12 for higher resolution (slower)
elev_raster <- get_elev_raster(
  locations = rainier_bbox,
  prj       = prj,
  z         = 10,
  clip      = "bbox"
)

# Convert to matrix for rayshader
elmat <- raster_to_matrix(elev_raster)

# Cache to data/ so you don't re-fetch every session
dir.create("data", showWarnings = FALSE)
saveRDS(elmat, "data/rainier_elmat.rds")
writeRaster(elev_raster, "data/rainier_elev.tif", overwrite = TRUE)

cat("Elevation matrix dimensions:", dim(elmat), "\n")
cat("Elevation range (m):", range(elmat, na.rm = TRUE), "\n")