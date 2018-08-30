#!/usr/bin/env julia

module Driver

using Unitful, BPJSpec
using FileIO, JLD2
include("../setup-matplotlib.jl")

const fiducial = load("122-quadratic-estimator-calibrated-all-moderate-spherical.jld2", "signal-model")

function defaults(; hidey=false)
    #plot(kmodel, Pmodel, "k-.", label="140 mK model signal")
    axhspan(10^2, 140^2, facecolor="w", alpha=0.5)

    #gca()[:set_xscale]("log")
    gca()[:set_yscale]("log")

    xlim(0.0, 0.4)
    ylim(10^4, 10^10.5)

    xlabel(L"k\,/\,\textrm{Mpc}^{-1}")
    if hidey
        hide_yaxis_labels()
    else
        ylabel(L"\Delta_{21}^2\,/\,\textrm{mK}^2")
    end
    #grid("on")
    tight_layout()
end

function fix_units(k, p)
    # put in dimensionless power spectrum units
    p = k.^3 ./ (2π^2) .* p
    # put in units of mK
    δ = 1e6 .* (abs.(p))
    #δ = 1e3 .* sqrt.(abs.(p))
    δ
end

function fix_units(k, p, σ)
    # put in dimensionless power spectrum units
    pmiddle = k.^3 ./ (2π^2) .* p
    pupper  = k.^3 ./ (2π^2) .* (p + 2σ)
    plower  = k.^3 ./ (2π^2) .* (p - 2σ)
    # put in units of mK
    δmiddle = 1e6 .* (abs.(pmiddle))
    δupper  = 1e6 .* (abs.(pupper))
    δlower  = 1e6 .* (abs.(plower))
    #δmiddle = 1e3 .* sqrt.(abs.(pmiddle))
    #δupper  = 1e3 .* sqrt.(abs.(pupper))
    #δlower  = 1e3 .* sqrt.(abs.(plower))
    δmiddle, abs.(δmiddle - δlower), abs.(δupper - δmiddle)
end

function getp(filename)
    load(filename, "minvariance-p", "minvariance-covariance", "minvariance-window-functions")
end

function getq(filename)
    q, M⁻¹, Σ, W = load(filename, "q", "minvariance-inverse-mixing-matrix",
                        "minvariance-covariance", "minvariance-window-functions")
    p = M⁻¹ \ q
    p, Σ, W
end

function windowed_ks(W)
    k = ustrip(fiducial.k)
    N = length(k)
    k′ = zeros(N)
    σk = zeros(N)
    for idx = 1:N
        max_index = indmax(W[idx, :])
        range = max(1, max_index-2):min(N, max_index+2)
        k′[idx] = sum(W[idx, range] .* k[range])
        σk[idx] = sum(W[idx, range] .* abs.(k[range] .- k′[idx]))
    end
    k′, σk
end

const color_dict = Dict("red"    => "#d62728",
                        "black"  => "#000000",
                        "blue"   => "#1f77b4",
                        "white"  => "#ffffff",
                        "yellow" => "#f4d35e",
                        "orange" => "#f49749",
                        "red2"   => "#df465a")

function plot_ps(p, Σ, W; color="black", error_color=color, do_errors=false)
    σ = sqrt.(diag(Σ))
    k, σk = windowed_ks(W)
    p, σlower, σupper = fix_units(k, p, σ)
    errorbar(k, p, fmt=".", yerr=(σlower, σupper), color=color_dict[color])
    if do_errors
        perm = sortperm(k)
        myk = k[perm]
        myσ = σupper[perm]
        plot(myk, myσ, "--", color=color_dict[error_color])
    end
end

function plot_ps_no_errors(p, W; color="black")
    k, σk = windowed_ks(W)
    p = fix_units(k, p)
    plot(k, p, ".", color=color_dict[color])
end

function filter_strength()
    #ppeel1,  Σpeel1,  Wpeel1  = getp("122-quadratic-estimator-peeled-all-mild-spherical.jld2")
    #ppeel2,  Σpeel2,  Wpeel2  = getp("122-quadratic-estimator-peeled-all-moderate-spherical.jld2")
    #ppeel3,  Σpeel3,  Wpeel3  = getp("122-quadratic-estimator-peeled-all-extreme-spherical.jld2")
    pcalib1, Σcalib1, Wcalib1 = getp("122-quadratic-estimator-calibrated-all-mild-spherical.jld2")
    pcalib2, Σcalib2, Wcalib2 = getp("122-quadratic-estimator-calibrated-all-moderate-spherical.jld2")
    pcalib3, Σcalib3, Wcalib3 = getp("122-quadratic-estimator-calibrated-all-extreme-spherical.jld2")

    figure(1, figsize=(6, 4)); clf()
    plot_ps(pcalib1, Σcalib1, Wcalib1, color="yellow", do_errors=true)
    title(L"\textrm{mild foreground filtering}", fontsize=14)
    defaults()
    make_white()
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-filter-strength-1.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)

    figure(2, figsize=(6, 4)); clf()
    plot_ps(pcalib1, Σcalib1, Wcalib1, color="yellow", do_errors=true)
    plot_ps(pcalib2, Σcalib2, Wcalib2, color="orange", do_errors=true)
    title(L"\textrm{moderate foreground filtering}", fontsize=14)
    defaults()
    make_white()
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-filter-strength-2.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)

    figure(3, figsize=(6, 4)); clf()
    plot_ps(pcalib1, Σcalib1, Wcalib1, color="yellow", do_errors=true)
    plot_ps(pcalib2, Σcalib2, Wcalib2, color="orange", do_errors=true)
    plot_ps(pcalib3, Σcalib3, Wcalib3, color="red2", do_errors=true)
    title(L"\textrm{extreme foreground filtering}", fontsize=14)
    defaults()
    make_white()
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-filter-strength-3.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)


    #figure(2, figsize=(6, 4)); clf()
    #plot_ps(ppeel1, Σpeel1, Wpeel1, color="orange",   do_errors=true)
    #plot_ps(ppeel2, Σpeel2, Wpeel2, color="white", do_errors=true)
    #plot_ps(ppeel3, Σpeel3, Wpeel3, color="yellow",  do_errors=true)
    #title(L"\textrm{with point source removal}", fontsize=14)
    #defaults()
    #make_white()
    #savefig(joinpath(@__DIR__, "spherical-power-spectrum-filter-strength-2.pdf"),
    #        bbox_inches="tight", pad_inches=0.1, transparent=true)
end

function simulations()
    p, _, W = getq("122-quadratic-estimator-predicted-peeled-moderate-spherical.jld2")

    pgsmall, _, Wgsmall = getq("122-quadratic-estimator-peeled-small-gain-errors-moderate-spherical.jld2")
    pgmediu, _, Wgmediu = getq("122-quadratic-estimator-peeled-medium-gain-errors-moderate-spherical.jld2")
    pglarge, _, Wglarge = getq("122-quadratic-estimator-peeled-large-gain-errors-moderate-spherical.jld2")

    pbsmall, _, Wbsmall = getq("122-quadratic-estimator-peeled-small-bandpass-errors-moderate-spherical.jld2")
    pbmediu, _, Wbmediu = getq("122-quadratic-estimator-peeled-medium-bandpass-errors-moderate-spherical.jld2")
    pblarge, _, Wblarge = getq("122-quadratic-estimator-peeled-large-bandpass-errors-moderate-spherical.jld2")

    figure(4, figsize=(6, 4)); clf()
    plot_ps_no_errors(pgsmall, Wgsmall, color="yellow")
    title(L"\textrm{0.1\% gain errors}", fontsize=14)
    defaults()
    make_white()
    xlim(0.05, 0.25)
    ylim(1e4, 1e11)
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-gain-errors-1.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)

    figure(5, figsize=(6, 4)); clf()
    plot_ps_no_errors(pgsmall, Wgsmall, color="yellow")
    plot_ps_no_errors(pgmediu, Wgmediu, color="orange")
    title(L"\textrm{1\% gain errors}", fontsize=14)
    defaults()
    make_white()
    xlim(0.05, 0.25)
    ylim(1e4, 1e11)
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-gain-errors-2.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)

    figure(6, figsize=(6, 4)); clf()
    plot_ps_no_errors(pgsmall, Wgsmall, color="yellow")
    plot_ps_no_errors(pgmediu, Wgmediu, color="orange")
    plot_ps_no_errors(pglarge, Wglarge, color="red2")
    title(L"\textrm{10\% gain errors}", fontsize=14)
    defaults()
    make_white()
    xlim(0.05, 0.25)
    ylim(1e4, 1e11)
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-gain-errors-3.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)

    figure(7, figsize=(6, 4)); clf()
    plot_ps_no_errors(pbsmall, Wbsmall, color="yellow")
    plot_ps_no_errors(pbmediu, Wbmediu, color="orange")
    plot_ps_no_errors(pblarge, Wblarge, color="red2")
    title(L"\textrm{random bandpass errors}", fontsize=14)
    defaults()
    make_white()
    xlim(0.05, 0.25)
    ylim(1e4, 1e11)
    savefig(joinpath(@__DIR__, "spherical-power-spectrum-bandpass-errors.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)
end

function go()
    #filter_strength()
    simulations()
end

end

Driver.go()

