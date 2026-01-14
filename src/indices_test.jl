using ArchGDAL
using BenchmarkTools
using GeoIO
using GeoStats
using Rasters

# ==============================================================================
# 1. SETUP & PATHS
# ==============================================================================
const TIF_PATH = raw"C:\Users\marco\OneDrive\Documents\Julia\GeoTests - Copia\bench\ortho.tif"
const GPKG_PATH = raw"C:\Users\marco\OneDrive\Documents\Julia\GeoTests\data\benchpoly.gpkg"

# ==============================================================================
# 2. GEOSTATS.JL APPROACH (Unstructured / View-based)
# ==============================================================================
println("--- Starting GeoStats.jl Benchmarks ---")

# Load data using GeoIO (returns a GeoTable)
geostats_grid = GeoIO.load(TIF_PATH)
geostats_poly_table = GeoIO.load(GPKG_PATH)

# Extract the geometry object (Polygon)
geo_poly = geostats_poly_table.geometry[1]
grid_geom = geostats_grid.geometry

# BENCHMARK 1: Finding Indices
# How long does it take to find which grid indices intersect the polygon?
println("Benchmarking GeoStats indices search:")
@btime indices(grid_geom, geo_poly);
# 2.118 s (1875060 allocations: 3.83 GiB)

# BENCHMARK 2: Subsetting (Clipping)
# This creates a 'View' (SubDomain). It does not copy data, just references it.
println("Benchmarking GeoStats subsetting (view creation):")
@btime geostats_grid[geo_poly, :];
# 3.673 s (3264225 allocations: 4.04 GiB)

# ==============================================================================
# 3. RASTERS.JL APPROACH (Grid-based / Array-based)
# ==============================================================================
println("\n--- Starting Rasters.jl Benchmarks ---")

# Load Raster lazily (only reads metadata initially)
raster_lazy = Raster(TIF_PATH, lazy=true)

# Load Polygon using pure ArchGDAL (as requested)
ag_poly = ArchGDAL.read(GPKG_PATH) do ds
  layer = ArchGDAL.getlayer(ds, 0)
  feat = first(layer) # Efficiently get the first feature

  # Extract geometry and clone it to Julia memory
  # We clone to ensure it persists after the dataset closes
  ArchGDAL.clone(ArchGDAL.getgeom(feat))
end


println("Benchmarking Rasters.jl optimized pipeline (Crop -> Mask):")

# Reduces the domain to the bounding box of the polygon
# Sets pixels inside the bounding box but outside the polygon to 'missing'
@btime mask(crop(raster_lazy; to=ag_poly); with=ag_poly);
# 15.008 s (15442376 allocations: 1.16 GiB)

# ==============================================================================
# 4. VALIDATION & EXPORT
# ==============================================================================

# Create the final object for export
final_raster = mask(crop(raster_lazy; to=ag_poly); with=ag_poly)

println("\nDone! Ready to save 'final_raster'.")
# write("C:\\Users\\marco\\OneDrive\\Documents\\Julia\\GeoTests - Copia\\bench\\output_crop.tif", final_raster)