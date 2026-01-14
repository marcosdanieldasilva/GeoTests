import time
import geopandas as gpd
import rasterio
from rasterio.mask import mask
from shapely.geometry import box

# --- File Configuration ---
# Using raw strings (r"...") to handle Windows backslashes correctly
vec_file = r"C:\Users\marco\OneDrive\Documents\Julia\GeoTests\data\benchpoly.gpkg"
ras_file = r"C:\Users\marco\OneDrive\Documents\Julia\GeoTests - Copia\bench\ortho.tif"

print("--- Preparation ---")
print("1. Loading vector data...")
gdf = gpd.read_file(vec_file)

print("2. Reading raster metadata...")
with rasterio.open(ras_file) as src:
    ras_crs = src.crs
    ras_bounds = src.bounds
    # We keep metadata if we want to write the file later
    ras_meta = src.meta.copy() 

# Ensure CRS alignment before benchmarking (this is prep work, not part of the clip test)
if gdf.crs != ras_crs:
    print(f"Reprojecting vector from {gdf.crs} to {ras_crs}...")
    gdf = gdf.to_crs(ras_crs)
else:
    print("CRS are already aligned.")

# ==============================================================================
# TEST 1: SPATIAL INDEX SELECTION
# Goal: Measure how fast we can filter only the polygons that touch 
# the raster area using the spatial index (R-tree).
# ==============================================================================
print("\n" + "="*40)
print("STARTING TEST 1: Spatial Index Selection (Query)")
print("="*40)

# Create a polygon representing the raster bounding box
raster_box = box(*ras_bounds)

start_idx = time.perf_counter()

# GeoPandas uses the spatial index automatically here to optimize the intersection
gdf_subset = gdf[gdf.intersects(raster_box)]

end_idx = time.perf_counter()

time_idx = end_idx - start_idx
print(f"Selection Time:   {time_idx:.4f} seconds")
print(f"Total Polygons:   {len(gdf)}")
print(f"Selected Polygons: {len(gdf_subset)}")


# ==============================================================================
# TEST 2: CLIP (Rasterio Mask)
# Goal: Crop the raster using the geometry mask.
# Note: We use 'gdf_subset' because passing thousands of non-overlapping 
# polygons to rasterio is inefficient.
# ==============================================================================
print("\n" + "="*40)
print("STARTING TEST 2: Clip (Mask)")
print("="*40)

if len(gdf_subset) == 0:
    print("Warning: No polygons overlap with the raster. Clip skipped.")
else:
    # Rasterio mask expects a list of geometries
    shapes = list(gdf_subset.geometry)

    start_clip = time.perf_counter()

    with rasterio.open(ras_file) as src:
        # crop=True adjusts the output raster extent to fit the shapes
        out_image, out_transform = mask(src, shapes, crop=True)

    end_clip = time.perf_counter()

    time_clip = end_clip - start_clip

    print(f"Clip Time:        {time_clip:.4f} seconds")
    print(f"Result Shape:     {out_image.shape}")
    print("-" * 40)
    print(f"TOTAL TIME (Index + Clip): {time_idx + time_clip:.4f} seconds")