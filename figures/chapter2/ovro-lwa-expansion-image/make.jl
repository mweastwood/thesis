#!/usr/bin/env julia

module Driver

using FITSIO
include("../setup-matplotlib.jl")


function create_image(filename, label=true)
    fits = FITS(filename)
    img  = read(fits[1])[:, :, 1, 1].'
    #img  = img[1:4:end, 1:4:end]
    hdr  = read_header(fits[1])

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

    max = +75
    min = -25
    base = 10
    
    figure(1, figsize=figsize, dpi=dpi); clf()
    gcf()[:subplots_adjust](left=0, right=1, bottom=0, top=1)

    radius = 1
    circle = plt[:Circle]((0, 0), radius, alpha=0)
    gca()[:add_patch](circle)

    imshow(img, extent=(-1, 1, -1, 1),
           vmin=min, vmax=max,
           origin="lower", interpolation="none", cmap=get_cmap("afmhot"),
           aspect="auto", clip_path=circle)

    xlim(-1, 1)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:axis]("off")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    #colorbar()

    savefig(joinpath("ovro-lwa-expansion-image.pdf"), transparent=true)

    tight_layout()

    # Note: the following line seems to shrink the image somewhat and put a small margin around
    # the edge of the image.
    #savefig("test.png", bbox_inches="tight", pad_inches=0, transparent=true)

    nothing
end

function go()
    create_image("sGRBint-image_mask.fits")
end

end

Driver.go()

