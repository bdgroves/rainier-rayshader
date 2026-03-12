# Placeholder for snowpack integration
# Intended workflow:
#   1. Load snowpack raster (SWE or % normal) aligned to rainier_elev.tif
#   2. Use generate_altitude_overlay() or a custom color ramp
#   3. Pass as add_overlay() layer into the rayshader pipeline
#
# Useful functions to explore:
#   - generate_altitude_overlay()
#   - generate_polygon_overlay()  # for SNOTEL station locations
#   - render_points()             # for SNOTEL stations in 3D

library(rayshader)

elmat <- readRDS("data/rainier_elmat.rds")

# TODO: load your snowpack data here
# snowpack_raster <- raster::raster("data/snowpack_swe.tif")