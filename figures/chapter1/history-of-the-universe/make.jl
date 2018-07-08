#!/usr/bin/env julia

module Driver

using Cosmology
using NLopt
include("../setup-matplotlib.jl")

const HI = 1420.40575177 # MHz
const cosmology = Cosmology.FlatLCDM{Float64}(0.69,                # h
                                              0.7099122024007928,  # ΩΛ
                                              0.29,                # Ωm
                                              8.77975992071536e-5) # Ωr

function vline_and_label(z, label)
    r = comoving_radial_dist_mpc(cosmology, z)
    axvline(r, color="k")
    text(r+50, -0.95, label, rotation=90,
         verticalalignment="bottom",
         fontsize=11)
    r
end

function plot_and_label(z, y, icon, label)
    r = comoving_radial_dist_mpc(cosmology, z)
    plot(r, y, icon, markersize=8, zorder=5)
    text(r+100, y, label,
         verticalalignment="center",
         fontsize=10, backgroundcolor="white", zorder=4)
    r
end

function shade_between(z1, z2, y1, y2, color, label)
    r1 = comoving_radial_dist_mpc(cosmology, z1)
    r2 = comoving_radial_dist_mpc(cosmology, z2)
    rect = plt[:Rectangle]((r1, y1), r2-r1, y2-y1, facecolor=color,
                           alpha=0.5, zorder=6)
    gca()[:add_patch](rect)
    text(r1+50, y2, label, fontsize=12, zorder=5,
         verticalalignment="bottom",
         backgroundcolor="white")
end

function age2distance(age)
    # First figure out the redshift for this age
    opt = Opt(:LN_SBPLX, 1)
    min_objective!(opt, (z, g) -> abs2(age_gyr(cosmology, z[1]) - age))
    lower_bounds!(opt, [0.0])
    upper_bounds!(opt, [10000.0])
    f, z, result = optimize(opt, [0.0])
    comoving_radial_dist_mpc(cosmology, z[1])
end

function go()
    figure(1, figsize=(8, 4)); clf()
    rcmb   = vline_and_label(1100, L"\textrm{surface of last scattering}")
    rstars = vline_and_label(  30, L"\textrm{first stars form?}")
    rionb  = vline_and_label(  12, L"\textrm{reionization begins?}")
    rione  = vline_and_label(   6, L"\textrm{reionization ends?}")

    plot_and_label( 7.085, 0.90, ".", L"\textrm{Mortlock et al. 2011}")
    plot_and_label( 7.54,  0.75, ".", L"\textrm{Bañados et al. 2017}")
    plot_and_label( 8.68,  0.60, "*", L"\textrm{Zitrin et al. 2015}")
    plot_and_label(11.09,  0.45, "*", L"\textrm{Oesch et al. 2016}")

    shade_between(HI/85,  HI/30, -0.55, 0.25, "red",  L"\textrm{OVRO-LWA}")
    shade_between(HI/250, HI/50, -0.75, 0.05, "blue", L"\textrm{HERA}")

    xlim(8000, rcmb)
    ylim(-1, 1)
    xlabel(L"\textrm{comoving distance} / \textrm{Mpc}", fontsize=14)
    hide_yaxis_labels()

    ages = [1, 10, 50, 100, 200, 500, 1000] # Myr
    distances = age2distance.(ages ./ 1000)

    ax1 = gca()
    ax2 = ax1[:twiny]()
    ax2[:set_xlim](ax1[:get_xlim]())
    ax2[:set_xticks](distances)
    ax2[:set_xticklabels](["\$$age\$" for age in ages])
    ax2[:set_xlabel](L"\textrm{age of the universe} / \textrm{Myr}", fontsize=14)
    # I want a little more space between the label and the axis
    ax2[:get_xaxis]()[:set_label_coords](0.5, 1.15)
    hide_yaxis_labels()

    tight_layout()

    savefig(joinpath(@__DIR__, "history-of-the-universe.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)

    nothing
end

end

Driver.go()

