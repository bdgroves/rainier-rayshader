library(sf)

# NPS official park boundaries dataset - this is the polygon layer
nps_url <- "https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/NPS_Land_Resources_Division_Boundary_and_Tract_Data_Service/FeatureServer/2/query?where=UNIT_CODE%3D'MORA'&outFields=*&outSR=4326&f=geojson"

rainier_boundary <- st_read(nps_url)

# Check what we got
cat("Geometry type:", as.character(st_geometry_type(rainier_boundary)), "\n")
cat("Number of features:", nrow(rainier_boundary), "\n")
cat("CRS:", st_crs(rainier_boundary)$input, "\n")

# Plot to verify it looks right
plot(st_geometry(rainier_boundary), main = "Mt. Rainier NP Boundary")

# Save
dir.create("data", showWarnings = FALSE)
st_write(rainier_boundary, "data/rainier_boundary.geojson", delete_dsn = TRUE)