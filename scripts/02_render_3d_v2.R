# Change these two values together
shadow_ray <- ray_shade(elmat, zscale = 75, lambert = TRUE)  # was 30
shadow_amb <- ambient_shade(elmat, zscale = 75)              # was 30

elmat |>
  sphere_shade(texture = "imhof4") |>
  add_water(detect_water(elmat), color = "imhof4") |>
  add_shadow(shadow_ray, 0.5) |>
  add_shadow(shadow_amb, 0) |>
  plot_3d(
    elmat,
    zscale      = 75,      # was 30 — try 50, 75, or 100
    fov         = 0,
    theta       = 135,
    phi         = 35,
    zoom        = 0.75,
    windowsize  = c(1200, 800),
    background  = "grey10",
    shadowcolor = "grey20"
  )