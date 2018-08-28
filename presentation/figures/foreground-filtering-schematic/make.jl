#!/usr/bin/env julia

using CasaCore.Measures
include("../setup-matplotlib.jl")

x = measure(ReferenceFrame(), Direction(dir"J2000", 1, 0, 0), dir"GALACTIC")
y = measure(ReferenceFrame(), Direction(dir"J2000", 0, 1, 0), dir"GALACTIC")
z = measure(ReferenceFrame(), Direction(dir"J2000", 0, 0, 1), dir"GALACTIC")

function lb2xy(l, b)
    θ = b
    for n = 1:5
        θ -= (2θ + sin(2θ) - π*sin(b))/(2 + 2cos(2θ))
    end
    x = 2*(l/π)*cos(θ)
    y =         sin(θ)
    x, y
end

function draw_graticule()
    for ldeg in (0, 30, 60, 90, 120, 150, 180)
        l = deg2rad(ldeg)
        θ = linspace(0, 2π, 512)
        x = 2 .* l .* cos.(θ) ./ π
        y = sin.(θ)
        plot(x, y, "w-", alpha=0.25, zorder=11)
    end
    for bdeg in (-60, -30, 0, 30, 60)
        b = deg2rad(bdeg)
        θ = b
        for n = 1:10
            θ -= (2θ + sin(2θ) - π*sin(b))/(2 + 2cos(2θ))
        end
        x = 2cos(θ)
        y =  sin(θ)
        plot([-x, x], [y, y], "w-", alpha=0.25, zorder=11)
    end
end

function draw_extent(north_dec, south_dec)
    θ = linspace(0, 2π, 1000)
    xcoords = Float64[]
    ycoords = Float64[]
    for dec in (north_dec, south_dec), idx = 1:length(θ)
        direction = Direction(sind(dec)*z + cosd(dec)*cos(θ[idx])*x
                                          + cosd(dec)*sin(θ[idx])*y)
        l = -longitude(direction)
        b =   latitude(direction)
        xy = lb2xy(l, b)
        push!(xcoords, xy[1])
        push!(ycoords, xy[2])
        # check to see if we wrapped around and add the arc of the ellipse if we did
        if length(xcoords) > 2 && abs(xcoords[end] - xcoords[end-1]) > 1 &&
                                  abs(ycoords[end] - ycoords[end-1]) < 0.1
            x2 = pop!(xcoords)
            y2 = pop!(ycoords)
            x1 = pop!(xcoords)
            y1 = pop!(ycoords)
            θ1 = atan2(2y1, x1)
            θ2 = atan2(2y2, x2)
            θrange = linspace(θ1, θ2)
            append!(xcoords, 2 .* cos.(θrange))
            append!(ycoords,      sin.(θrange))
        end
    end
    ellipse = plt[:Polygon]([xcoords ycoords], color="w", alpha=0.5, lw=0)
    gca()[:add_patch](ellipse)
end

figure(1, figsize=(6, 3)); clf()
draw_graticule()
draw_extent(+75, -46)
draw_extent(+63, -35)
draw_extent(+43, -23)
xlim(-2.01, 2.01)
ylim(-1.01, 1.01)
gca()[:set_aspect]("equal")
gca()[:get_xaxis]()[:set_visible](false)
gca()[:get_yaxis]()[:set_visible](false)
axis("off")
tight_layout()
savefig(joinpath(@__DIR__, "foreground-filtering-schematic.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

