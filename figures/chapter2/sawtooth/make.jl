#!/usr/bin/env julia

using FileIO, JLD2
include("../setup-matplotlib.jl")

function make_plot()
    flags = load("002-raw-data-flags.jld2", "flags")
    sawtooth = flags.sawtooth[:, 1, :]
    dB = 10 .* log10.(sawtooth)

    t = ((1:size(sawtooth, 1)) .- 1) * 13/60

    figure(1, figsize=(8, 4)); clf()
    for ant = 33:36 # just pick a nice range of antennas
        plot(t, dB[:, ant], "k-", alpha=1)
    end
    xlim(0, 120)
    ylim(-0.05, 0.05)
    xlabel(L"\textrm{time}\,/\,\textrm{minutes}")
    ylabel(L"\textrm{gain amplitude}/\,\textrm{dB}")
    grid("on")

    tight_layout()

    savefig(joinpath(@__DIR__, "sawtooth.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

make_plot()

