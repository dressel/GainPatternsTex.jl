# GainPatternsTex

This package allows plotting of gain patterns.
It requires the GainPatterns package to be used before:
```
using GainPatterns
using GainPatternsTex
```
I made this package because I was finding it tedious to create these plots.
PGF allows you to make polar plots, but you can't have negative values.
This means you have to shift all gains so the lowest one is zero, and then shift the axis labels back.
This package takes care of all that.

## Requirements
You need the Julia package PGFPlots to generate the plots.
PGFPlots requires you to have LaTeX set up on your computer.

## Plotting
A brief overview is shown here, but check out the [examples](http://nbviewer.ipython.org/github/dressel/GainPatterns.jl/blob/master/doc/GainPatterns.ipynb).
For some reason, the notebook viewer has been acting oddly in Firefox.
If the axis labels don't show up in the examples, try looking at the exmples in another browser.

Plots can be created with:
```
plot(gp)			# plot single GainPattern
plot([gp1, gp2])	# plot multiple GainPatterns on same axis
```

`plot` creates a PolarAxis object (from PGFPlots package).
Currently, it doesn't show anything to the screen (does show in IJulia notebook though).
Use PGFPlots's `save` function to save the file as a PDF or tex file.

```
p = plot(gp)
save("plot.pdf", p)		# saves plot as pdf
save("plot.tex", p)		# saves plot as tex file
```

Optional arguments give you greater control over your plots:
* `ymin`
* `ymax`
* `lastleg` 
* `style` style (only use if plotting one pattern).
* `styles` Vector of possible LaTeX styles (use if plotting multiple patterns).
* `showsamples`
* `degrees` Set this to true if you want the angles to have degrees.
* `legendentries` Vector of strings. Length must match length of vector of GainPatterns to plot.

In Julia, optional arguments require you to include the argument name.
Order does not matter.
```
plot(gp, ymin=-100)
plot([gp1,gp2], legendentires=["plot1", "plot2"], degrees=true)
```

[![Build Status](https://travis-ci.org/dressel/GainPatternsTex.jl.svg?branch=master)](https://travis-ci.org/dressel/GainPatternsTex.jl)
