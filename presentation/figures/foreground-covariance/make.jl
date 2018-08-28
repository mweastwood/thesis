#!/usr/bin/env julia

using Unitful
using FileIO, JLD2
using NLopt
include("../setup-matplotlib.jl")

l = 10:300
p, Σ = load("123-angular-quadratic-estimator.jld2", "p", "covariance")
frequencies = [71.9784e6,
               72.2856e6,
               72.54e6,
               72.78e6,
               73.02e6,
               73.26e6,
               73.5e6,
               73.74e6,
               73.98e6,
               74.22e6,
               74.4e6] # Hz

function make_plot(idx)
    @show idx
    selection = fill(true, length(l))
    selection[30 .≤ l .≤ 35] = false # these data points have a weird feature, don't use them in the fit
    selection[l .> 250] = false

    figure(idx, figsize=(6, 4)); clf()
    errorbar(l, p[idx], yerr=2sqrt.(diag(Σ[idx])), fmt="r.", ms=0, zorder=10)
    xlim(10, 250)
    ylim(1e-1, 1e5)
    #gca()[:set_xscale]("log")
    gca()[:set_yscale]("log")
    #grid("on")
    xlabel(L"l")
    ylabel(L"C_l\,/\,\textrm{K}^2")

    str = @sprintf("%.3f", frequencies[idx]/1e6)
    text(245, 5e4, "\$$str\\,\\textrm{MHz}\$", fontsize=16,
         horizontalalignment="right", verticalalignment="top", color="white")
    
    A = 700 / (1000)^2 # K²
    β = 2.4
    α = 2.80
    santos_cooray_knox(l, ν) = A * (1000/l)^β * (130/ν)^(2α)
    plot(l, santos_cooray_knox.(l, frequencies[idx]/1e6), "w-.", zorder=3)
    text(245, 7e-1, L"\textrm{Santos et al. 2005}", zorder=2,
         fontsize=12, verticalalignment="bottom", rotation=-7,
         horizontalalignment="right", color="white")
    
    # Fit a power law to the measured data.
    power_law(x) = x[1] .* (l./100).^x[2]
    double_power_law(x) = (x[1] .* (l./100).^(x[2] .+ x[3] .* (l .- 100)))
    residuals1(x) = p[idx] - power_law(x)
    residuals2(x) = p[idx] - double_power_law(x)
    chi_squared1(x, g) = (r = residuals1(x)[selection]; r'*(Σ[idx][selection, selection]\r))
    chi_squared2(x, g) = (r = residuals2(x)[selection]; r'*(Σ[idx][selection, selection]\r))
    
    opt = Opt(:LN_SBPLX, 2)
    lower_bounds!(opt, [  10; -4])
    upper_bounds!(opt, [1000; -2])
    min_objective!(opt, chi_squared1)
    χ², x, _ = optimize(opt, [100; -3])
    @show x
    
    opt = Opt(:LN_SBPLX, 3)
    lower_bounds!(opt, [  10; -4.0; -1.0])
    upper_bounds!(opt, [1000; -0.5; +1.0])
    min_objective!(opt, chi_squared2)
    χ², y, _ = optimize(opt, [100; -3; 0])
    @show y

    plot(l, power_law(x), "w--", zorder=10)
    plot(l, double_power_law(y), "w-", zorder=10)

    tight_layout()
    make_white()

    savefig(joinpath(@__DIR__, @sprintf("foreground-covariance-%02d.pdf", idx)),
            bbox_inches="tight", pad_inches=0.1, transparent=true)
end

function make_spectrum_plot()
    power = zeros(length(p[1]), length(p))
    for idx = 1:length(p)
        power[:, idx] = p[idx]
    end
    mean_power = squeeze(mean(power, 2), 2)

    selection = fill(true, length(l))
    selection[30 .≤ l .≤ 35] = false # these data points have a weird feature, don't use them in the fit
    selection[l .> 250] = false

    # Fit a power law to the measured data.
    power_law(x, β) = x[1] .* (frequencies[β]/73.152e6).^x[2] .* mean_power
    function chi_squared(x, g)
        output = 0.0
        for β = 1:11
            r  = (p[β] .- power_law(x, β))[selection]
            co = Σ[β][selection, selection]
            output += r'*(co\r)
        end
        output
    end

    opt = Opt(:LN_SBPLX, 2)
    lower_bounds!(opt, [0.1; -5])
    upper_bounds!(opt, [2.0; -1])
    min_objective!(opt, chi_squared)
    ftol_rel!(opt, 1e-10)
    χ², x, _ = optimize(opt, [1; -3])
    @show x

    for index in linspace(-2, -5, 100)
        @show index, chi_squared([1.0, index], [])
    end
end

make_plot(6)

