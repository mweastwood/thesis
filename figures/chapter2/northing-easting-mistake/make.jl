#!/usr/bin/env julia

module Driver

using FITSIO
include("../setup-matplotlib.jl")


function create_image(filename1, filename2, output)
    fits = FITS(filename1)
    img1 = read(fits[1])[:, :, 1, 1].'

    fits = FITS(filename2)
    img2 = read(fits[1])[:, :, 1, 1].'

    hdr  = read_header(fits[1])
    img  = img1 - img2

    datetime = DateTime(hdr["DATE-OBS"])
    julian   = Dates.datetime2julian(datetime)
    modified_julian = julian - 2400000.5

    N = size(img, 1)
    Δ = abs(hdr["CDELT1"]) |> deg2rad

    stretch = N*Δ/2
    M = round(Int, N/stretch)
    δ = (N - M) ÷ 2
    img = img[δ:end-δ, δ:end-δ]

    dpi = 256
    figsize = (1024÷dpi, 1024÷dpi)

    figure(1, figsize=figsize, dpi=dpi); clf()
    gcf()[:subplots_adjust](left=0, right=1, bottom=0, top=1)

    radius = 1
    circle = plt[:Circle]((0, 0), radius, alpha=0)
    gca()[:add_patch](circle)

    imshow(img, extent=(-1, 1, -1, 1),
           vmin=-1000, vmax=1000,
           origin="lower", interpolation="none", cmap=get_cmap("magma"),
           aspect="auto", clip_path=circle)

    center = (-0.217, 0.278)
    radius = 0.15
    θlist  = linspace(π/16, 2π - π/16)
    path  = [(radius*sin(θ) + center[1], -radius*cos(θ) + center[2]) for θ in θlist]
    arrow = mpl_patches.FancyArrowPatch(path=mpl_path.Path(path),
                                        arrowstyle="-|>,head_width=2,head_length=4",
                                        color="white")

    text(-0.421,  0.603, L"\textrm{Cas A}", horizontalalignment="center", color="white")
    text(-0.019, -0.068, L"\textrm{Cyg A}", horizontalalignment="center", color="white")

    gca()[:add_patch](arrow)

    xlim(-1, 1)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:axis]("off")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    #colorbar()

    savefig(joinpath(output), transparent=true)

    tight_layout()

    # Note: the following line seems to shrink the image somewhat and put a small margin around
    # the edge of the image.
    #savefig("test.png", bbox_inches="tight", pad_inches=0, transparent=true)

    nothing
end

function go()
    create_image("dada2ms-image.fits", "newdada2ms-image.fits", "northing-easting-mistake.pdf")
end

end

Driver.go()

