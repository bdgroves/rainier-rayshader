# rainier-rayshader

3D rayshader visualizations of Mt. Rainier and surrounding National Park,
with hooks for snowpack overlay data.

## Setup
1. Clone the repo
2. Open `rainier-rayshader.Rproj` in RStudio
3. Run `renv::restore()` to install dependencies
4. Run scripts in order: `scripts/01_get_elevation.R` → `02_render_3d.R`

## Data
Elevation data is fetched automatically via `elevatr` and cached to `data/`.
Not committed to git due to file size.