# =============================================================================
# Mt. Rainier Rayshader 3D Render
# 02_render_3d.R
#
# Prerequisites: run 00_get_boundary.R first to generate
#   data/rainier_boundary.geojson
#
# Outputs:
#   data/rainier_elmat.rds       — cached elevation matrix
#   data/rainier_elev.tif        — cached elevation raster
#   outputs/rainier_3d_clipped.png
# =============================================================================

library(elevatr)
library(raster)
library(rayshader)
library(sf)
library(dplyr)

# ── 1. Load & clean boundary ──────────────────────────────────────────────────
cat("Loading park boundary...\n")

rainier_boundary <- st_read("data/rainier_boundary.geojson") |>
  st_transform(4326) |>
  st_union() |>
  st_cast("POLYGON") |>
  st_as_sf() |>
  mutate(area = st_area(x)) |>
  filter(area == max(area))   # drop any detached fragments

cat("Boundary loaded. Geometry type:",
    as.character(st_geometry_type(rainier_boundary)), "\n")

# ── 2. Fetch elevation ────────────────────────────────────────────────────────
cat("Fetching elevation data (z=11, this may take a minute)...\n")

elev_raster <- get_elev_raster(
  locations = rainier_boundary,
  z         = 11,
  clip      = "locations"
)

# Crop to tight bbox THEN mask to polygon shape
elev_cropped <- crop(elev_raster, extent(rainier_boundary))
elev_masked  <- mask(elev_cropped, as(rainier_boundary, "Spatial"))

# Cache raw masked raster for later use (snowpack overlay etc.)
dir.create("data", showWarnings = FALSE)
writeRaster(elev_masked, "data/rainier_elev.tif", overwrite = TRUE)

cat("Elevation range (m):",
    range(values(elev_masked), na.rm = TRUE), "\n")

# ── 3. Fill NA boundary edges to prevent vertical streaking ───────────────────
cat("Smoothing NA boundary edges...\n")

# Two-pass focal fill: interpolates NA cells from real neighbours
# NAonly = TRUE means real data values are never altered
elev_filled <- focal(
  elev_masked,
  w      = matrix(1, 5, 5),
  fun    = mean,
  na.rm  = TRUE,
  NAonly = TRUE
)
elev_filled <- focal(
  elev_filled,
  w      = matrix(1, 9, 9),
  fun    = mean,
  na.rm  = TRUE,
  NAonly = TRUE
)

# ── 4. Convert to matrix & trim empty borders ─────────────────────────────────
elmat <- raster_to_matrix(elev_filled)

elmat <- elmat[
  apply(elmat, 1, function(x) !all(is.na(x))),
  apply(elmat, 2, function(x) !all(is.na(x)))
]

cat("Final matrix dimensions:", dim(elmat), "\n")

saveRDS(elmat, "data/rainier_elmat.rds")

# ── 5. Build shading layers ───────────────────────────────────────────────────
cat("Computing ray shade (this takes a few minutes at z=11)...\n")
shadow_ray <- ray_shade(elmat, zscale = 70, lambert = TRUE)

cat("Computing ambient shade...\n")
shadow_amb <- ambient_shade(elmat, zscale = 70)

# ── 6. Build texture ──────────────────────────────────────────────────────────
texture <- sphere_shade(elmat, sunangle = 315, texture = "desert")

# Quick 2D sanity check — should show warm tan/brown tones
cat("Plotting 2D preview...\n")
plot_map(texture)

# ── 7. Render 3D ──────────────────────────────────────────────────────────────
cat("Rendering 3D scene...\n")

texture |>
  add_shadow(shadow_ray, 0.5) |>
  add_shadow(shadow_amb, 0.1) |>
  plot_3d(
    elmat,
    zscale      = 70,       # vertical exaggeration — increase to flatten
    fov         = 45,       # perspective field of view
    theta       = 225,      # horizontal rotation (SW view centers Rainier)
    phi         = 35,       # camera elevation angle
    zoom        = 0.65,
    windowsize  = c(1200, 800),
    background  = "grey10",
    shadowcolor = "grey20",
    soliddepth  = -50       # depth of the base slab
  )

Sys.sleep(0.5)

# ── 8. Save snapshot ──────────────────────────────────────────────────────────
dir.create("outputs", showWarnings = FALSE)
render_snapshot("outputs/rainier_3d_clipped.png", clear = FALSE)
cat("Snapshot saved to outputs/rainier_3d_clipped.png\n")

# ── 9. Optional: high quality render ─────────────────────────────────────────
# Uncomment when you're happy with the camera angle.
# Takes 5-15 min depending on samples — start with samples=64, go to 256 for final.
#
# render_highquality(
#   filename        = "outputs/rainier_hq.png",
#   samples         = 64,
#   lightdirection  = c(315, 315),
#   lightaltitude   = c(45, 10),
#   lightintensity  = c(400, 100),
#   scale_text_size = 24,
#   clear           = TRUE
# )

cat("\n--- Done! ---\n")
cat("Rotate the RGL window interactively to find your preferred angle.\n")
cat("Then run render_camera() to lock in the view, and render_snapshot() to save.\n")
cat("Useful camera adjustment commands:\n")
cat("  render_camera(theta=225, phi=35, zoom=0.65, fov=45)\n")
cat("  render_snapshot('outputs/rainier_custom_angle.png')\n")