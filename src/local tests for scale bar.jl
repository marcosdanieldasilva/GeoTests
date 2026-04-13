# load required packages
using GLMakie
using Meshes
using GeoTables
using CoordRefSystems

println("Starting Viewer Validation Test Suite...\n")

# ==========================================
# SCENARIO 1: 2D CartesianGrid (Implicit Linear)
# Expected outcome: Scale bar drawn successfully
# ==========================================
println("Running Scenario 1: 2D Cartesian Grid (scale=true)")

gridcartesian = CartesianGrid(100, 100)
geodatacartesian = georef((Signal=rand(10000),), gridcartesian)

# Should draw scale bar because CRS is 'nothing' (implicitly linear)
fig1 = viewer(geodatacartesian, scale=true, colormap=:viridis)
display(fig1)
println("Result 1: Plotted. Please verify the scale bar is visible.\n")


# ==========================================
# SCENARIO 2: 2D Projected CRS (Explicit Linear)
# Expected outcome: Scale bar drawn successfully
# ==========================================
println("Running Scenario 2: 2D Projected CRS / WebMercator (scale=true)")

xs = range(1000.0, 2000.0, length=20)
ys = range(1000.0, 2000.0, length=20)
pointsproj = [Meshes.Point(WebMercator(x, y)) for x in xs, y in ys]
domproj = PointSet(vec(pointsproj))
geodataproj = georef((Signal=rand(400),), domproj)

# Should draw scale bar because WebMercator <: CoordRefSystems.Projected
fig2 = viewer(geodataproj, scale=true)
display(fig2)
println("Result 2: Plotted. Please verify the scale bar is visible.\n")


# ==========================================
# SCENARIO 3: 2D Geographic CRS (Angular)
# Expected outcome: Warning in terminal, NO scale bar
# ==========================================
println("Running Scenario 3: 2D Geographic CRS / LatLon (scale=true)")

lats = range(-30.0, -29.0, length=20)
lons = range(-54.0, -53.0, length=20)
pointsgeo = [Meshes.Point(LatLon(lat, lon)) for lat in lats, lon in lons]
domgeo = PointSet(vec(pointsgeo))
geodatageo = georef((Signal=rand(400),), domgeo)

# Should trigger warning: "Unsupported coordinate system detected..."
fig3 = viewer(geodatageo, scale=true)
display(fig3)
println("Result 3: Plotted. Please verify the scale bar is NOT visible.\n")


# ==========================================
# SCENARIO 4: 2D Polar CRS (Non-linear mapping)
# Expected outcome: Warning in terminal, NO scale bar
# ==========================================
println("Running Scenario 4: 2D Polar CRS (scale=true)")

radii = range(1.0, 10.0, length=20)
angles = range(0.0, 2pi, length=20)
pointspolar = [Meshes.Point(Polar(r, theta)) for r in radii, theta in angles]
dompolar = PointSet(vec(pointspolar))
geodatapolar = georef((Signal=rand(400),), dompolar)

# Should trigger warning: "Unsupported coordinate system detected..."
fig4 = viewer(geodatapolar, scale=true, colormap=:plasma)
display(fig4)
println("Result 4: Plotted. Please verify the scale bar is NOT visible.\n")


# ==========================================
# SCENARIO 5: 3D Grid
# Expected outcome: Warning in terminal (3D), NO scale bar
# ==========================================
println("Running Scenario 5: 3D Cartesian Grid (scale=true)")

grid3d = CartesianGrid(10, 10, 10)
geodata3d = georef((Signal=rand(1000),), grid3d)

# Should trigger warning: "3D domain detected..."
fig5 = viewer(geodata3d, scale=true, colormap=:cividis)
display(fig5)
println("Result 5: Plotted in 3D. Please verify the scale bar is NOT visible.\n")


# ==========================================
# SCENARIO 6: Scale parameter explicitly false
# Expected outcome: Default behavior, NO scale bar, NO warnings
# ==========================================
println("Running Scenario 6: 2D Cartesian Grid (scale=false)")

# Should NOT trigger any warnings, should NOT draw scale bar
fig6 = viewer(geodatacartesian, scale=false, colormap=:grays)
display(fig6)
println("Result 6: Plotted. Please verify the scale bar is NOT visible and no warnings were issued.\n")

println("Test Suite Completed.")
