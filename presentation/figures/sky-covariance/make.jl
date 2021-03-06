#!/usr/bin/env julia

include("../setup-matplotlib.jl")

ν = [7.19784e7,
     7.22856e7,
     7.254e7,
     7.278e7,
     7.302e7,
     7.326e7,
     7.35e7,
     7.374e7,
     7.398e7,
     7.422e7,
     7.44e7]

# C(100, ν[1], ν)
signal_covariance_ν = [+8.89499e-10,
                       +5.28252e-10,
                       +1.70886e-10,
                       -4.84683e-11,
                       -1.62411e-10,
                       -1.97712e-10,
                       -1.82737e-10,
                       -1.42273e-10,
                       -9.53416e-11,
                       -5.44965e-11,
                       -3.14616e-11]

# C(l, ν[1], ν[1])
signal_covariance_l = [8.73628e-10, 8.73786e-10, 8.73945e-10, 8.74104e-10, 8.74262e-10,
                       8.74421e-10, 8.7458e-10, 8.74739e-10, 8.74897e-10, 8.75056e-10, 8.75215e-10,
                       8.75373e-10, 8.75532e-10, 8.75691e-10, 8.7585e-10, 8.76008e-10, 8.76167e-10,
                       8.76326e-10, 8.76484e-10, 8.76643e-10, 8.76802e-10, 8.76961e-10,
                       8.77119e-10, 8.77278e-10, 8.77437e-10, 8.77595e-10, 8.77754e-10,
                       8.77913e-10, 8.78072e-10, 8.7823e-10, 8.78389e-10, 8.78548e-10, 8.78706e-10,
                       8.78865e-10, 8.79024e-10, 8.79183e-10, 8.79341e-10, 8.795e-10, 8.79659e-10,
                       8.79817e-10, 8.79976e-10, 8.80135e-10, 8.80294e-10, 8.80452e-10,
                       8.80611e-10, 8.8077e-10, 8.80928e-10, 8.81087e-10, 8.81246e-10, 8.81404e-10,
                       8.81563e-10, 8.81722e-10, 8.81881e-10, 8.82039e-10, 8.82198e-10,
                       8.82357e-10, 8.82515e-10, 8.82674e-10, 8.82833e-10, 8.82992e-10, 8.8315e-10,
                       8.83309e-10, 8.83468e-10, 8.83626e-10, 8.83785e-10, 8.83944e-10,
                       8.84103e-10, 8.84261e-10, 8.8442e-10, 8.84579e-10, 8.84737e-10, 8.84896e-10,
                       8.85055e-10, 8.85214e-10, 8.85372e-10, 8.85531e-10, 8.8569e-10, 8.85848e-10,
                       8.86007e-10, 8.86166e-10, 8.86325e-10, 8.86483e-10, 8.86642e-10,
                       8.86801e-10, 8.86959e-10, 8.87118e-10, 8.87277e-10, 8.87436e-10,
                       8.87594e-10, 8.87753e-10, 8.87912e-10, 8.8807e-10, 8.88229e-10, 8.88388e-10,
                       8.88547e-10, 8.88705e-10, 8.88864e-10, 8.89023e-10, 8.89181e-10, 8.8934e-10,
                       8.89499e-10, 8.89658e-10, 8.89816e-10, 8.89975e-10, 8.90134e-10,
                       8.90292e-10, 8.90451e-10, 8.9061e-10, 8.90768e-10, 8.90927e-10, 8.91174e-10,
                       8.91442e-10, 8.9171e-10, 8.91981e-10, 8.92251e-10, 8.92523e-10, 8.92797e-10,
                       8.9307e-10, 8.93346e-10, 8.93622e-10, 8.93899e-10, 8.94178e-10, 8.94456e-10,
                       8.94736e-10, 8.95018e-10, 8.95299e-10, 8.95582e-10, 8.95865e-10,
                       8.96149e-10, 8.96435e-10, 8.96721e-10, 8.97007e-10, 8.97295e-10,
                       8.97583e-10, 8.97872e-10, 8.98161e-10, 8.98452e-10, 8.98743e-10,
                       8.99034e-10, 8.99327e-10, 8.9962e-10, 8.99913e-10, 9.00208e-10, 9.00502e-10,
                       9.00797e-10, 9.01093e-10, 9.0139e-10, 9.01687e-10, 9.01984e-10, 9.02282e-10,
                       9.0258e-10, 9.02879e-10, 9.03178e-10, 9.03478e-10, 9.03778e-10, 9.04078e-10,
                       9.04379e-10, 9.0468e-10, 9.04982e-10, 9.05284e-10, 9.05586e-10, 9.05888e-10,
                       9.06191e-10, 9.06494e-10, 9.06798e-10, 9.07101e-10, 9.07405e-10,
                       9.07709e-10, 9.08014e-10, 9.08318e-10, 9.08622e-10, 9.08927e-10,
                       9.09232e-10, 9.09537e-10, 9.09843e-10, 9.10148e-10, 9.10454e-10,
                       9.10759e-10, 9.11065e-10, 9.11371e-10, 9.11677e-10, 9.11983e-10,
                       9.12288e-10, 9.12594e-10, 9.129e-10, 9.13206e-10, 9.13512e-10, 9.13818e-10,
                       9.14124e-10, 9.1443e-10, 9.14736e-10, 9.15042e-10, 9.15347e-10, 9.15653e-10,
                       9.15959e-10, 9.16264e-10, 9.16569e-10, 9.16874e-10, 9.17179e-10,
                       9.17485e-10, 9.17789e-10, 9.18094e-10, 9.18398e-10, 9.18702e-10,
                       9.19007e-10, 9.1931e-10, 9.19614e-10, 9.19917e-10, 9.2022e-10, 9.20523e-10,
                       9.20826e-10, 9.21128e-10, 9.2143e-10, 9.21732e-10, 9.22034e-10, 9.22335e-10,
                       9.22636e-10, 9.22937e-10, 9.23237e-10, 9.23538e-10, 9.23837e-10,
                       9.24136e-10, 9.24435e-10, 9.24734e-10, 9.25033e-10, 9.2533e-10, 9.25627e-10,
                       9.25924e-10, 9.26221e-10, 9.26519e-10, 9.26814e-10, 9.27109e-10,
                       9.27404e-10, 9.27699e-10, 9.27994e-10, 9.28287e-10, 9.2858e-10, 9.28872e-10,
                       9.29165e-10, 9.29457e-10, 9.29749e-10, 9.30036e-10, 9.30323e-10, 9.3061e-10,
                       9.30897e-10, 9.31184e-10, 9.31467e-10, 9.31747e-10, 9.32028e-10,
                       9.32308e-10, 9.32588e-10, 9.32868e-10, 9.33146e-10, 9.33423e-10, 9.337e-10,
                       9.33976e-10, 9.34253e-10, 9.3453e-10, 9.34803e-10, 9.35077e-10, 9.3535e-10,
                       9.35623e-10, 9.35896e-10, 9.36169e-10, 9.36439e-10, 9.36708e-10,
                       9.36978e-10, 9.37247e-10, 9.37516e-10, 9.37785e-10, 9.38052e-10,
                       9.38317e-10, 9.38582e-10, 9.38847e-10, 9.39112e-10, 9.39377e-10, 9.3964e-10,
                       9.39901e-10, 9.40161e-10, 9.40422e-10, 9.40682e-10, 9.40943e-10,
                       9.41204e-10, 9.41459e-10, 9.41715e-10, 9.41971e-10, 9.42227e-10,
                       9.42483e-10, 9.42739e-10, 9.42992e-10, 9.43243e-10, 9.43494e-10,
                       9.43745e-10, 9.43996e-10, 9.44247e-10, 9.44497e-10, 9.44745e-10, 9.4499e-10,
                       9.45236e-10, 9.45481e-10, 9.45727e-10]

figure(1, figsize=(6, 4)); clf()

subplot(2, 1, 1)
plot(0:300, signal_covariance_l*1e9, "w-")
grid("on")
xlabel(L"l")
ylabel(L"C_l\,/\,10^{-9}\,\textrm{K}^2")
xlim(0, 300)
gca()[:get_yaxis]()[:set_label_coords](-0.1, 0.5)
make_white()

subplot(2, 1, 2)
plot((ν-ν[1]) / 1e6, signal_covariance_ν*1e9, "w-")
grid("on")
xlabel(L"\Delta\nu\,/\,\textrm{MHz}")
ylabel(L"C_l\,/\,10^{-9}\,\textrm{K}^2")
xlim(0, 2.5)
gca()[:get_yaxis]()[:set_label_coords](-0.1, 0.5)
make_white()

tight_layout()

savefig(joinpath(@__DIR__, "sky-covariance.pdf"),
        bbox_inches="tight", pad_inches=0.1, transparent=true)

