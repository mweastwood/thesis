from __future__ import division
from pylab import *
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

class LogNormalize(colors.Normalize):
    def __init__(self, vmin=None, vmax=None, base=None, cutoff=None, clip=False):
        self.base   = base
        self.cutoff = cutoff
        colors.Normalize.__init__(self, vmin, vmax, clip)

# julia> function colorscale(value, vmin, vmax, base, cutoff)
#            a = cutoff + base
#            b = cutoff - base
#            c = log(base + cutoff)
#            x0 = log(base + vmax)
#            y0 = log(base - vmin)
#            denominator = 2*cutoff/a + x0 + y0 - 2*c
#            if value > cutoff
#                x = log(base + value)
#                numerator = x - 2*c + y0 + 2*cutoff/a
#                return numerator / denominator
#            elseif value < -cutoff
#                y = log(base - value)
#                numerator = -y + y0
#                return numerator / denominator
#            else
#                numerator = (value + cutoff)/a + y0 - c
#                return numerator / denominator
#            end
#        end

    def __call__(self, values, clip=None):
        base   = self.base
        cutoff = self.cutoff

        values = maximum(values, self.vmin)
        values = minimum(values, self.vmax)

        a = cutoff + base
        b = cutoff - base
        c = log(base + cutoff)
        idx = values >= +cutoff
        jdx = values <= -cutoff
        kdx = abs(values) < cutoff
        x = log(base + values[idx])
        y = log(base - values[jdx])
        x0 = log(base + self.vmax)
        y0 = log(base - self.vmin)

        output = np.ma.masked_array(values.copy())
        output[:] = 0

        denominator = 2*cutoff/a + x0 + y0 - 2*c

        # values >= cutoff
        numerator = x - 2*c + y0 + 2*cutoff/a
        output[idx] = numerator / denominator

        # values <= cutoff
        numerator = -y + y0
        output[jdx] = numerator / denominator

        # abs(values) < cutoff
        numerator = (values[kdx] + cutoff)/a + y0 - c
        output[kdx] = numerator / denominator

        return output

