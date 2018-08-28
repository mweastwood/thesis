using Cosmology
using PyPlot
using LibHealpix

srand(123)

cosmo = cosmology()

function comoving(z)
    comoving_radial_dist_mpc(cosmo,z)
end

function age(z)
    age_gyr(cosmo,z)
end

@doc """
Create a realization of a Gaussian random field with similar statistical
properties to the CMB.
""" ->
function gencmb()
    lmax = mmax = 300
    alm = Alm(Complex128,lmax,mmax)
    C = zeros(lmax+1)
    for l = 1:lmax
        C[l+1] = (1/3 * exp(-(log(l)-log(1))^2/(log(100)-log(1))^2) # ISW
                  + exp(-(log(l)-log(200))^2/(log(400)-log(200))^2) # first harmonic
                  + 1/3 * exp(-(log(l)-log(500))^2/(log(600)-log(500))^2)) # second harmonic
    end
    for m = 0:mmax, l = m:lmax
        alm[l,m] = complex(randn(),randn()) * sqrt(C[l+1]/(l+1)^2)
    end
    mollweide(alm2map(alm,512))
end
mockcmb = gencmb()

@doc """
Create a matplotlib path corresponding to a closed donut shape.
""" ->
function pyplot_donut(rinner,router)
    θinner = linspace(0,2π,1000)
    θouter = linspace(2π,0,1000)
    x = [rinner*cos(θinner);router*cos(θouter)]
    y = [rinner*sin(θinner);router*sin(θouter)]
    plt[:Polygon]([x y],alpha=0)
end

function circle(r;color="white")
    θ = linspace(0,2π,1000)
    x = r*cos(θ)
    y = r*sin(θ)
    plot(x,y,"-",color=color)
end

function donut(r1,r2;color="white")
    θ1 = linspace(0,2π,1000)
    θ2 = linspace(2π,0,1000)
    x = [r1*cos(θ1);r2*cos(θ2)]
    y = [r1*sin(θ1);r2*sin(θ2)]
    fill(x,y,edgecolor=color,facecolor=color)
end

function wedge(r,θ1,θ2;color="white")
    θ = linspace(θ1,θ2,1000)
    x = [0;r*cos(θ);0]
    y = [0;r*sin(θ);0]
    fill(x,y,edgecolor=color,facecolor=color)
end

function sun()
    annotate(L"$\odot$",(0,0),
             horizontalalignment="center",
             verticalalignment="center",
             color="#ffffff",
             size="x-large")
end

function cmb()
    r = comoving(1100)
    d = pyplot_donut(r,15000)
    gca()[:add_patch](d)
    i = imshow(mockcmb,
               extent=(-30000,30000,-15000,15000),
               cmap=get_cmap("jet"),
               interpolation="lanczos",
               clip_path=d)
end

function redshift(z)
    r = comoving(z)
    circle(r)
    annotate(@sprintf("z = %.1f",z),(0,r+500),
             horizontalalignment="center",
             verticalalignment="center",
             color="#ffffff")
end

function calendar(z)
    r = comoving(z)
    circle(r)
    date = Date(2015) + Dates.Day(round(age(z)/age(0)*365))
    month = Dates.monthname(date)
    if length(month) > 4
        month = month[1:3]*"."
    end
    str = month * " " * string(Dates.day(date))
    annotate(str,(0,r+500),
             horizontalalignment="center",
             verticalalignment="center",
             color="#ffffff")
end

function radiotelescope(name,z1,z2,color)
    r1 = comoving(z1)
    r2 = comoving(z2)
    donut(r1,r2,color=color)
    annotate(name,(0,(r1+r2)/2),
             horizontalalignment="center",
             verticalalignment="center",
             color="#000000")
end

function setup()
    figure(1,figsize=(10,10)); clf()
    xlim(-15000,15000)
    ylim(-15000,15000)
    grid("off")
    axis("off")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    gca()[:set_aspect]("equal")
end

function savepdf(filename)
    savefig(filename,bbox_inches="tight",pad_inches=0,transparent=true)
end

function frame1()
    setup()
    #sun()
    cmb()
    r = comoving(1100)
    t = age(0)
    annotate("Last Scattering\nSurface",(0,r-750),
             horizontalalignment="center",
             verticalalignment="top",
             color="#ffffff")
    annotate("",(0,0),(r,0),
             arrowprops = Dict("arrowstyle" => "<->",
                               "edgecolor" => "white"))
    annotate(@sprintf("%d Mpc",round(Int,r/1000)*1000),(r/2,500),
             horizontalalignment="center",
             verticalalignment="center",
             color="#ffffff")
    annotate(@sprintf("%d Gyr",round(Int,t)),(r/2,-700),
             horizontalalignment="center",
             verticalalignment="center",
             color="#ffffff")
    savepdf("scalemap1.pdf")
end

function frame2()
    setup()
    cmb()
    r = comoving(10)
    wedge(r,0,deg2rad(2.4/60))
    annotate("Hubble Ultra Deep Field",(0,0),
             horizontalalignment="left",
             verticalalignment="bottom",
             color="#ffffff")
    savepdf("scalemap2.pdf")
end

function frame3()
    setup()
    cmb()
    wedge(comoving(0.22),-2.5/12*π,+2.5/12*π)
    wedge(comoving(0.22),π-2.5/12*π,π+2.5/12*π)
    annotate("2dF",(0,-750),
             horizontalalignment="center",
             verticalalignment="top",
             color="#ffffff")
    savepdf("scalemap3.pdf")
end

function frame4()
    srand(123)
    setup()
    cmb()
    wedge(comoving(0.22),-2.5/12*π,+2.5/12*π)
    wedge(comoving(0.22),π-2.5/12*π,π+2.5/12*π)
    radiotelescope("LWA",1420/75-1,1420/40-1,"#ff8a80")
    radiotelescope("PAPER",7,12,"#fff980")
    radiotelescope("CHIME",1420/800-1,1420/400-1,"#91ff80")
    savepdf("scalemap4.pdf")
end

#=
function frame3()
    setup()
    sun()
    cmb()
    redshift(0.5)
    redshift(1)
    redshift(2)
    redshift(5)
    redshift(10)
    redshift(20)
    redshift(50)
    savepdf("scalemap3.pdf")
end

function frame4()
    setup()
    sun()
    cmb()
    calendar(0.5)
    calendar(1)
    calendar(2)
    calendar(5)
    calendar(10)
    calendar(20)
    calendar(50)
    savepdf("scalemap4.pdf")
end

function frame5()
    setup()
    sun()
    cmb()
    radiotelescope("LWA",1420/85-1,1420/30-1,"#ff8a80")
    savepdf("scalemap5.pdf")
end

function frame6()
    setup()
    sun()
    cmb()
    radiotelescope("LWA",1420/75-1,1420/45-1,"#ff8a80")
    radiotelescope("PAPER",7,12,"#fff980")
    radiotelescope("CHIME",1420/800-1,1420/400-1,"#91ff80")
    savepdf("scalemap6.pdf")
end

frame1()
frame2()
frame3()
frame4()
frame5()
frame6()
=#


#=
function universe_map()
    c = cosmology()

    figure(1); clf()
    scatter(0,0,color="#ffffff")
    @draw_circle c 1100 "#ffffff" # CMB
    @fill_between c 1420/85-1 1420/30-1 "#ff8a80" # LWA
    @fill_between c 7 12 "#fff980" # PAPER
    @fill_between c 1420/800-1 1420/400-1 "#91ff80" # CHIME

    # Redshift surveys
    @draw_wedge c 0.03 0.30 "#00c8d6" # CfA1 (de Lapparent et al. 1986)
    @draw_wedge c 0.03 0.60 "#00c8d6" # ORS (Santiago et al. 1995)
    @draw_wedge c 0.17 0.01 "#00c8d6" # LCRS (Shectman et al. 1996)
    @draw_wedge c 0.04 0.60 "#00c8d6" # SSRS2+ (de Costa et al. 1998)
    # CfA2 (Huchra et al. 1999)
    @draw_wedge c 0.08 0.85 "#00c8d6" # IRAS PSCz (Saunders et al. 2000)
    @draw_wedge c 0.19 0.08 "#00c8d6" # 2dF (Colless et al. 2001)
    @draw_wedge c 0.10 0.41 "#00c8d6" # 6dFGS (Jones et al. 2004, 2005, 2009)
    @draw_wedge c 0.33 0.35 "#00c8d6" # SDSS DR8 main galaxy sample (Aihara et al. 2011)
    @draw_wedge c 0.05 0.91 "#00c8d6" # 2MRS (Huchra et al. 2012)

    #@draw_wedge c 0.0 0.0 "#00c8d6" # DEEP2
    #@draw_wedge c 0.0 0.0 "#00c8d6" # CNOC2
    #@draw_wedge c 0.0 0.0 "#00c8d6" # AGES
    #@draw_wedge c 0.0 0.0 "#00c8d6" # GAMA
    #@draw_wedge c 0.0 0.0 "#00c8d6" # MGC
    #@draw_wedge c 0.0 0.0 "#00c8d6" # SSRS2
    #@draw_wedge c 0.0 0.0 "#00c8d6" # 2SLAQ
    #@draw_wedge c 0.0 0.0 "#00c8d6" # VIPERS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # VVDS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # zCOSMOS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # QCD
    #@draw_wedge c 0.0 0.0 "#00c8d6" # WiggleZ
    #@draw_wedge c 0.0 0.0 "#00c8d6" # AARS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # CfA ???
    #@draw_wedge c 0.0 0.0 "#00c8d6" # ESP
    #@draw_wedge c 0.0 0.0 "#00c8d6" # H-AAO
    #@draw_wedge c 0.0 0.0 "#00c8d6" # KPGRS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # SAPM
    #@draw_wedge c 0.0 0.0 "#00c8d6" # CFRS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # DEEP
    #@draw_wedge c 0.0 0.0 "#00c8d6" # FDF
    #@draw_wedge c 0.0 0.0 "#00c8d6" # GDDS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # K20
    #@draw_wedge c 0.0 0.0 "#00c8d6" # LBG-z3
    #@draw_wedge c 0.0 0.0 "#00c8d6" # MUNICS
    #@draw_wedge c 0.0 0.0 "#00c8d6" # TKRS
    #@draw_wedge c 0.0 0.0 "#00c8d6" #
    #@draw_wedge c 0.0 0.0 "#00c8d6" #
    #@draw_wedge c 0.0 0.0 "#00c8d6" #


    #@draw_wedge c 0.15 0.41 "#00c8d6" # 6dFGS (Heath Jones et al. 2009)

    #for z = 1:5
        #@draw_circle c z "k--"
    #end
    #@draw_circle c 10 "r-"
    #@fill_between c 0.3 0 "#FF0000" # SDSS
    #@fill_between c 1420/70-1 1420/30-1 "#348ABD"
    #@fill_between c 1420/300-1 1420/100-1 "#348ABD"
    gca()[:set_aspect]("equal")
    xlim(-15000,15000)
    ylim(-15000,15000)
    axis("off")
end
=#

