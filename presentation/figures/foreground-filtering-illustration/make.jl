#!/usr/bin/env julia

using FileIO, JLD2
include("../setup-matplotlib.jl")

m, B, N, S, F, L, W = load("201-example-foreground-filtering-block.jld2",
                           "m", "B", "N", "S", "F", "L", "W")

function display(X, skip, global_max; vmin=-15)
    logX = log10.(abs.(X[1:skip:end, 1:skip:end]) ./ global_max)
    logX[isinf.(logX)] .= vmin
    imshow(logX, vmin=vmin, vmax=0,
           cmap=get_cmap("magma_r"), origin="upper")
    gca()[:set_aspect]("equal")
    hide_xaxis_labels()
    hide_yaxis_labels()
    #colorbar()
end

S = B*S*B'
F = B*F*B'
skip = 55
global_max = max(maximum(abs.(S)), maximum(abs.(F)), maximum(abs.(N)))

figure(1, figsize=(12, 4)); clf()
subplot(1, 3, 1)
display(N, skip, global_max)
title(L"\textrm{noise covariance matrix}")
make_white()
subplot(1, 3, 2)
display(S, skip, global_max)
title(L"\textrm{signal covariance matrix}")
make_white()
subplot(1, 3, 3)
display(F, skip, global_max)
title(L"\textrm{foreground covariance matrix}")
tight_layout()
make_white()
gcf()[:subplots_adjust](wspace=0, hspace=0.1)

savefig(joinpath(@__DIR__, "foreground-filtering-illustration-1.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

N = L'*N*L
S = L'*S*L
F = L'*F*L
skip = 22
global_max = max(maximum(abs.(S)), maximum(abs.(F)), maximum(abs.(N)))

figure(2, figsize=(12, 4)); clf()
subplot(1, 3, 1)
display(N, skip, global_max, vmin=-10)
title(L"\textrm{noise covariance matrix}")
make_white()
subplot(1, 3, 2)
display(S, skip, global_max, vmin=-10)
title(L"\textrm{signal covariance matrix}")
make_white()
subplot(1, 3, 3)
display(F, skip, global_max, vmin=-10)
title(L"\textrm{foreground covariance matrix}")
make_white()
tight_layout()
gcf()[:subplots_adjust](wspace=0, hspace=0.1)

savefig(joinpath(@__DIR__, "foreground-filtering-illustration-2.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

N = W'*(N+F)*W
S = W'*S*W
skip = 22
global_max = max(maximum(abs.(S)), maximum(abs.(F)), maximum(abs.(N)))

figure(3, figsize=(12, 4)); clf()
subplot(1, 3, 1)
display(N, skip, global_max, vmin=-10)
title(L"\textrm{noise covariance matrix}")
make_white()
subplot(1, 3, 2)
display(S, skip, global_max, vmin=-10)
title(L"\textrm{signal covariance matrix}")
make_white()
subplot(1, 3, 3)
hide_xaxis_labels()
hide_yaxis_labels()
xlim(-1, 1)
ylim(-1, 1)
gca()[:set_aspect]("equal")
title(L"\textrm{foreground covariance matrix}")
make_white()
tight_layout()
gcf()[:subplots_adjust](wspace=0, hspace=0.1)

savefig(joinpath(@__DIR__, "foreground-filtering-illustration-3.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

