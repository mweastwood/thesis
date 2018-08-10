using PyCall, PyPlot
unshift!(PyVector(pyimport("sys")["path"]), @__DIR__)
@pyimport matplotlib.colors as mpl_colors
@pyimport matplotlib.patches as mpl_patches
@pyimport matplotlib.path as mpl_path

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

