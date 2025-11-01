using GeoStats, GeoIO

import CairoMakie as Mke

using BenchmarkTools

import GeoStats: indices

gtb = GeoIO.load(raw"G:\Meu Drive\Colab_SIG\disciplina_sr\dados_trigo\clusters.gpkg")

poly = gtb.geometry[1]

multipoly = Multi(gtb.geometry)

img = GeoIO.load(raw"G:\Meu Drive\Colab_SIG\disciplina_sr\dados_trigo\ngrdi_img_01.tif")

grid = img.geometry

img2 = img |> Upscale(50, 50)

grid2 = img2.geometry

@btime sideof((centroid(grid2, i) for i in 1:nelements(grid2)), boundary(poly))
# 40.581 ms (1398857 allocations: 40.88 MiB)

mask_sideof = findall(!=(OUT), sideof((centroid(grid2, i) for i in 1:nelements(grid2)), boundary(poly)))

function indice(grid::TransformedGrid, poly::Geometry)
  g = grid.mesh
  t = grid.transform
  parts = getfield(t, :transforms)
  affine = only(filter(x -> x isa Affine, parts))
  p = revert(affine, poly, nothing)
  return indices(g, p)
end

@btime indice(grid2, poly);
# 151.700 μs (265 allocations: 272.06 KiB)

mask_indice = indice(grid2, poly)

masked_img_sideof = img2[mask_sideof,:]

masked_img_indice = img2[mask_indice,:]

v1 = masked_img_sideof|> viewer

viz!(poly, color="red")

v1

v2 = masked_img_indice|> viewer

viz!(poly, color="red")

v2