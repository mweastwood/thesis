#!/usr/bin/env julia

using FileIO, JLD2
using Unitful, UnitfulAstro
using CasaCore.Measures
using TTCal
include("../setup-matplotlib.jl")

SEFD = load("200-system-equivalent-flux-density.jld2", "SEFD")
metadata = load("metadata.jld2", "metadata")

ν = metadata.frequencies
νmin = minimum(ν)
νmax = maximum(ν)

MHz(x) = ustrip(uconvert(u"MHz", x))
K(x)   = ustrip(uconvert(u"K", x))

function edges(ν)
    # Mozdzen et al. 2017 report a measurement of the absolute sky flux in the southern hemisphere
    # between 90 and 190 MHz. The brightness temperature at 150 MHz varies between 842 K at 17 h
    # LST, and 257 K at 2 H LST. The spectral index fluctuates between -2.6 and -2.5. The spectral
    # index tends to flatten as the sky temperature increases (presumably due to free-free
    high_temp = 842u"K" * (ν/150u"MHz")^-2.5
    low_temp  = 257u"K" * (ν/150u"MHz")^-2.6
    high_temp, low_temp
end

function leda(ν)
    low_temp  = 1700u"K" * (ν/70u"MHz")^-2.38
    high_temp = 3200u"K" * (ν/70u"MHz")^-2.28
    high_temp, low_temp
end

function plot_tsys(experiment; hatch=false)
    ν = linspace(νmin, νmax, 109)
    bounds = experiment.(ν)
    bottom = getindex.(bounds, 1)
    top    = getindex.(bounds, 2)
    if hatch
        fill_between(MHz.(ν), K.(bottom), K.(top),
                     facecolor="none", hatch="///", color="white")
    else
        fill_between(MHz.(ν), K.(bottom), K.(top),
                     facecolor="white", alpha=0.10)
    end
end

function sefd_to_tsys(sefd, ν)
    λ = u"c"/ν
    Ω = 2.4u"sr"
    κ = λ^2/(Ω*2u"k")
    uconvert(u"K", sefd * κ)
end

function index_to_lst(metadata, index)
    frame = ReferenceFrame(metadata)
    Measures.set!(frame, metadata.times[index])
    zenith = Direction(dir"AZEL", 0u"°", 90u"°")
    j2000  = measure(frame, zenith, dir"J2000")
    ra = longitude(j2000)
    mod(ustrip(ra) * 12/π, 24)
end

sefd_timeseries = squeeze(median(SEFD, 1), 1) .* u"Jy"
sefd_spectrum   = squeeze(median(SEFD, 2), 2) .* u"Jy"
tsys_timeseries = sefd_to_tsys.(sefd_timeseries, mean(ν))
tsys_spectrum   = sefd_to_tsys.(sefd_spectrum, ν[2:end-1])
lst = index_to_lst.(metadata, 2:Ntime(metadata)-1)

# smooth out the time series just a little bit
window = 1:64
lst = lst[1:length(window):6628]
tsys_timeseries_smoothed = zeros(length(lst))
while last(window) < length(tsys_timeseries)
    index = mod1(fld(first(window), length(window)), length(lst))
    tsys_timeseries_smoothed[index] = median(ustrip.(tsys_timeseries[window]))
    window += length(window)
end

# put the time series in order (so the plot doesn't wrap around)
perm = sortperm(lst)
lst = lst[perm]
tsys_timeseries_smoothed = tsys_timeseries_smoothed[perm]

function plot_sunrise_sunset(metadata)
    sun = Direction(dir"SUN")
    frame = ReferenceFrame(metadata)
    abovehorizon = false
    # NOTE: we only want one line for sunrise and two lines for sunset. In this dataset we actually
    # see two sunrises because it is 28 hours long but only one sunset. I don't want two sunrise
    # lines basically on top of eachother.
    did_sunrise = false
    did_sunset  = false
    for (idx, time) in enumerate(metadata.times)
        Measures.set!(frame, time)
        azel = measure(frame, sun, dir"AZEL")
        if !abovehorizon && latitude(azel) > 0
            #sunrise
            abovehorizon = true
            lst = index_to_lst(metadata, idx)
            if !did_sunrise
                axvline(lst, color="w", alpha=0.5,  zorder=3)
                text(lst, 100, L"\textrm{sunrise}", zorder=2,
                     fontsize=14, rotation=90,
                     verticalalignment="bottom",
                     horizontalalignment="right",
                     color="white")
                did_sunrise = true
            end
        elseif abovehorizon && latitude(azel) < 0
            # sunset
            abovehorizon = false
            lst = index_to_lst(metadata, idx)
            if !did_sunset
                axvline(lst, color="w", alpha=0.5, zorder=3)
                text(lst, 100, L"\textrm{sunset}", zorder=2,
                     fontsize=14, rotation=90,
                     verticalalignment="bottom",
                     horizontalalignment="right",
                     color="white")
                did_sunset = true
            end
        end
    end
end

figure(1, figsize=(6, 4)); clf()

subplot(2, 1, 1)
plot_tsys(edges)
plot_tsys(leda, hatch=false)
plot(MHz.(ν[2:end-1]), K.(tsys_spectrum), "w-")
xlim(MHz(νmin), MHz(νmax))
ylim(0, 6000)
xlabel(L"\nu\,/\,{\rm MHz}")
ylabel(L"(T_{\rm sys}\,/\,\eta)\,/\,{\rm K}")
#grid("on")
make_white()

subplot(2, 1, 2)
plot(lst, tsys_timeseries_smoothed, "w-")
plot_sunrise_sunset(metadata)
#hide_yaxis_labels()
xlim(0, 24)
ylim(0, 6000)
xticks(6:6:24)
xlabel(L"\textrm{local sidereal time}\,/\,{\rm hr}")
ylabel(L"(T_{\rm sys}\,/\,\eta)\,/\,{\rm K}")
#grid("on")

tight_layout()
make_white()
gcf()[:subplots_adjust](wspace=0)

savefig(joinpath(@__DIR__, "system-temperature.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

