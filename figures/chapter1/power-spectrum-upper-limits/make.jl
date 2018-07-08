#!/usr/bin/env julia

module Driver

include("../setup-matplotlib.jl")

function plot_and_label(z, y, icon, label)
    plot(z, y, icon, markersize=8, zorder=5)
    text(z[end]+0.2, y[end], label,
         verticalalignment="center",
         fontsize=10, backgroundcolor="white", zorder=4)
end

function shade_between(z1, z2, y1, y2, color)
    rect = plt[:Rectangle]((z1, y1), z2-z1, y2-y1, facecolor=color,
                           alpha=0.5, zorder=6)
    gca()[:add_patch](rect)
end

function go()
    figure(1, figsize=(8, 4)); clf()

    plot_and_label(7.7, 41, "v", L"\textrm{Parsons et al. 2014}")
    plot_and_label(8.4, 22.4, "v", L"\textrm{Ali et al. 2015}")
    plot_and_label((9.6+10.6)/2, 79.6, "v", L"\textrm{Patil et al. 2017}")
    plot_and_label([(11.5+12.9)/2, (14.5+16.2)/2, (16.2+17.9)/2],
                   [sqrt(10^7.5), sqrt(10^8.0), sqrt(10^8.5)],
                   "v-", L"\textrm{Ewall-Wice et al. 2016}")

    shade_between( 7, 15, 1,  10, "black")
    shade_between(15, 22, 1, 100, "black")

    text((15+22)/2, 100,
         L"\textrm{enhanced amplitude due to Bowman et al. 2018}",
         verticalalignment="bottom",
         horizontalalignment="center",
         backgroundcolor="white",
         fontsize=10)

    xlim(7, 22)
    ylim(1e0, 1e5)
    xlabel(L"\textrm{redshift}", fontsize=14)
    ylabel(L"\textrm{power spectrum amplitude} / \textrm{mK}", fontsize=14)
    grid("on")
    gca()[:set_yscale]("log")

    tight_layout()

    savefig(joinpath(@__DIR__, "power-spectrum-upper-limits.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)

    nothing
end

end

Driver.go()

