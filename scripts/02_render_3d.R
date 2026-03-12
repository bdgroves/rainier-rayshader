library(rayshader)
library(raster)

# Load cached elevation matrix
elmat <- readRDS("data/rainier_elmat.rds")

# Resize if needed for performance (0.5 = half resolution)
# Comment out for full res
# elmat <- resize_matrix(elmat, scale = 0.5)

# --- Shading layers ---
shadow_ray <- ray_shade(elmat, zscale = 30, lambert = TRUE)
shadow_amb <- ambient_shade(elmat, zscale = 30)

# --- Build texture and render ---
elmat |>
  sphere_shade(texture = "imhof4") |>
  add_water(detect_water(elmat), color = "imhof4") |>
  add_shadow(shadow_ray, 0.5) |>
  add_shadow(shadow_amb, 0) |>
  plot_3d(
    elmat,
    zscale      = 15,       # vertical exaggeration - tune to taste
    fov         = 0,
    theta       = 135,      # horizontal rotation
    phi         = 35,       # camera elevation angle
    zoom        = 0.75,
    windowsize  = c(1200, 800),
    water       = FALSE,    # Rainier has no significant standing water
    background  = "grey10",
    shadowcolor = "grey20"
  )

Sys.sleep(0.5)

# Save a snapshot to outputs/
dir.create("outputs", showWarnings = FALSE)
render_snapshot("outputs/rainier_3d_initial.png", clear = FALSE)

cat("Done! Rotate the rgl window interactively.\n")
cat("When happy with camera angle, run render_camera() to lock it in.\n")