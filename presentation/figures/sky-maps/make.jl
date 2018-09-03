#!/usr/bin/env julia

using LibHealpix
include("../setup-matplotlib.jl")

function decide_on_color_scale(img, vmin, vmax)
    pixels = vec(img)
    pixels = pixels[pixels .!= 0]
    sort!(pixels)
    N = length(pixels)
    #vmin   = pixels[round(Int, 0.0005N+1)]
    #vmax   = pixels[round(Int, 0.9990N+1)]
    base   = 500
    cutoff = min(1000, vmax-vmin)
    vmin, vmax, base, cutoff
end

function plot_map(filename; vmin=-5000, vmax=+20000)
    map = readhealpix(joinpath(@__DIR__, filename))
    _plot_map(map, vmin, vmax)
end

function plot_map_difference(filename1, filename2; vmin=-100, vmax=+100)
    map1 = readhealpix(joinpath(@__DIR__, filename1))
    map2 = readhealpix(joinpath(@__DIR__, filename2))
    _plot_map(map1 - map2, vmin, vmax)
end

function plot_map_fractional_difference(filename1, filename2; vmin=-100, vmax=+100)
    map1 = readhealpix(joinpath(@__DIR__, filename1))
    map2 = readhealpix(joinpath(@__DIR__, filename2))
    δ = (map1 .- map2) ./ (map1 .+ 2500)
    _plot_map(δ, vmin, vmax)
end

function _plot_map(map, vmin, vmax)
    img = mollweide(map)
    
    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    vmin, vmax, base, cutoff = decide_on_color_scale(img, vmin, vmax)
    imshow(img, cmap=get_cmap("magma"), origin="upper",
           norm=lognormalize.LogNormalize(vmin, vmax, base, cutoff),
           extent=(-2, 2, -1, 1),
           clip_path=ellipse, zorder=10)
    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    axis("off")
    tight_layout()
end

function show_colorbar(text=L"\textrm{brightness temperature}\,/\,\textrm{K}")
    cbar = colorbar()
    cbar[:set_label](text, fontsize=14, rotation=270, color="white")
    cbar[:ax][:get_yaxis]()[:set_label_coords](8.5, 0.5)
    cbar[:ax][:tick_params](axis="x", colors="white", which="both")
    cbar[:ax][:tick_params](axis="y", colors="white", which="both")
    cbar[:outline][:set_edgecolor]("white")
end

function draw_graticule()
    for ldeg in (0, 30, 60, 90, 120, 150)
        l = deg2rad(ldeg)
        θ = linspace(0, 2π, 512)
        x = 2 .* l .* cos.(θ) ./ π
        y = sin.(θ)
        plot(x, y, "w-", alpha=0.1, zorder=11)
    end
    for bdeg in (-60, -30, 0, 30, 60)
        b = deg2rad(bdeg)
        θ = b
        for n = 1:5
            θ -= (2θ + sin(2θ) - π*sin(b))/(2 + 2cos(2θ))
        end
        x = 2cos(θ)
        y =  sin(θ)
        plot([-x, x], [y, y], "w-", alpha=0.1, zorder=11)
    end
end

function label_sun()
    annotate(L"\textrm{The Sun}",
             xy=(-0.362, -0.63), xytext=(0.14, -0.63),
             fontsize=14, zorder=12,
             verticalalignment="center", color="white",
             arrowprops=Dict(:width=>1, :headwidth=>5, :headlength=>5,
                             :shrink=>0.05, :facecolor=>"white", :edgecolor=>"white"))
end

figure(1, figsize=(6, 2.5), dpi=120); clf()
plot_map("031-dirty-channel-map-filtered-recalibrated-all-moderate-0006.fits",
         vmin=-50, vmax=+50)
show_colorbar()
draw_graticule()
#label_sun()
make_white()
savefig(joinpath(@__DIR__, "filtered-sky-map-colorbar.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

figure(2, figsize=(6, 2.5), dpi=120); clf()
plot_map("031-dirty-channel-map-filtered-recalibrated-all-moderate-0009.fits",
         vmin=-50, vmax=+50)
show_colorbar()
draw_graticule()
#label_sun()
make_white()
savefig(joinpath(@__DIR__, "filtered-sky-map-colorbar-2.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

figure(3, figsize=(6, 2.5), dpi=120); clf()
plot_map_difference("031-dirty-map-interpolated-peeled-even.fits",
                    "031-dirty-map-interpolated-peeled-odd.fits",
                    vmin=-50, vmax=+50)
show_colorbar()
draw_graticule()
#label_sun()
savefig(joinpath(@__DIR__, "even-odd-sky-map-colorbar.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

figure(4, figsize=(6, 2.5), dpi=120); clf()
plot_map_fractional_difference(
    "031-dirty-channel-map-compressed-peeled-all-0005.fits",
    "031-dirty-channel-map-compressed-peeled-all-0006.fits",
    vmin=-0.05, vmax=+0.05)
show_colorbar(L"\textrm{fractional difference}")
draw_graticule()
#label_sun()
savefig(joinpath(@__DIR__, "channel-difference-sky-map-colorbar.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

figure(5, figsize=(6, 2.5)); clf()
plot_map("031-dirty-map-interpolated-peeled-all.fits")
savefig(joinpath(@__DIR__, "peeled-sky-map.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)
show_colorbar()
draw_graticule()
savefig(joinpath(@__DIR__, "peeled-sky-map-colorbar.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

#figure(6, figsize=(12, 5)); clf()
#plot_map_difference("031-dirty-map-interpolated-peeled-xx.fits",
#                    "031-dirty-map-interpolated-peeled-yy.fits",
#                    vmin=-2000, vmax=+2000)
#show_colorbar()
#draw_graticule()
#label_sun()
#savefig(joinpath(@__DIR__, "xx-yy-sky-map-colorbar.pdf"),
#        bbox_inches="tight", pad_inches=0, transparent=true)

