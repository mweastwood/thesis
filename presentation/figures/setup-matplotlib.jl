using PyCall, PyPlot
unshift!(PyVector(pyimport("sys")["path"]), @__DIR__)
@pyimport lognormalize
@pyimport matplotlib.colors as mpl_colors
@pyimport mpl_toolkits.axes_grid1 as tk

plt[:rc]("lines", linewidth=1.2)
plt[:rc]("font", family="sans-serif")
plt[:rc]("text", usetex=true)
plt[:rc]("text.latex", unicode=true, preamble=raw"""
         \usepackage{amsmath}
         """)
plt[:rc]("axes", linewidth=1.1, titlesize=16, labelsize=16)
plt[:rc]("xtick", labelsize=12)
plt[:rc]("xtick.major", size=3, width=1.1)
plt[:rc]("xtick.minor", size=2, width=1.0)
plt[:rc]("ytick", labelsize=12)
plt[:rc]("ytick.major", size=3, width=1.1)
plt[:rc]("ytick.minor", size=2, width=1.0)
plt[:rc]("legend", fontsize=11, framealpha=1.0)
plt[:rc]("image", aspect="auto", interpolation="nearest", origin="lower")

function hide_xaxis_labels()
    plt[:setp](gca()[:get_xticklabels](), visible=false)
    plt[:setp](gca()[:get_xticklines](),  visible=false)
end

function hide_yaxis_labels()
    plt[:setp](gca()[:get_yticklabels](), visible=false)
    plt[:setp](gca()[:get_yticklines](),  visible=false)
end

function make_white()
    gca()[:spines]["bottom"][:set_color]("white")
    gca()[:spines]["top"][:set_color]("white") 
    gca()[:spines]["right"][:set_color]("white")
    gca()[:spines]["left"][:set_color]("white")
    gca()[:tick_params](axis="x", colors="white", which="both")
    gca()[:tick_params](axis="y", colors="white", which="both")
    gca()[:yaxis][:label][:set_color]("white")
    gca()[:xaxis][:label][:set_color]("white")
    gca()[:title][:set_color]("white")
end

