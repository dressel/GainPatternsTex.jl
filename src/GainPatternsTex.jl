module GainPatternsTex

# package code goes here
using GainPatterns
export plot
import PGFPlots: PolarAxis, Plots, save, Axis
export PolarAxis, save, Axis

###########################################################################
# PLOTTING
###########################################################################
# Returns the PolarAxis object containing a plot of the gain pattern
function plot(gp::GainPattern; title=nothing, ymin::Real=0.0, ymax=nothing, showsamples::Bool=false, lastleg::Bool=true, style=nothing, degrees::Bool=false)
	plot([gp], title=title, ymin=ymin, ymax=ymax, showsamples=showsamples, lastleg=lastleg, styles=[style],degrees=degrees)
end

function plot(gp_array::Vector{GainPattern}; title=nothing,ymin::Real=0.0, ymax=nothing, showsamples::Bool=false, lastleg::Bool=true, legendentries=nothing, colors=nothing, styles=nothing, degrees::Bool=false)

	# Create an array with length of angles for each gain pattern
	# Create an array with minimum mean gain for each pattern
	# Initialize the minimum_gain to the lowest of these minimum gains
	num_gp = length(gp_array)
	mingain_array = zeros(num_gp)
	nangles_array = zeros(Int, num_gp)
	for i = 1:num_gp
		nangles_array[i] = length(gp_array[i].angles)
		mingain_array[i] = minimum(gp_array[i].meangains)
	end
	mingain = minimum(mingain_array)

	# Currently, only plot samples for one gain pattern
	# TODO: Don't allow legend entries for showing samples
	#  Or do, but it has to be done well...
	if showsamples && (num_gp == 1)
		gp = gp_array[1]
		for i = 1:nangles_array[1]
			tempmin = minimum(gp.samples[i])
			mingain = (tempmin < mingain ? tempmin : mingain)
		end

		ymin = min(ymin, mingain, 0.0)
		if typeof(ymax) != Void
			ymax -= ymin
			emsg = "ymax is smaller than smallest gain, 0, and specified ymin"
			ymax < ymin ? error(emsg) : nothing
		end

		gain_plot = plotgains(gp.angles, gp.meangains, ymin, lastleg)
		plot_array = plotsamples(gp.angles, gp.samples, ymin)
		push!(plot_array, gain_plot)
		pa = PolarAxis(plot_array, ymax=ymax, yticklabel="{\\pgfmathparse{$ymin+\\tick} \\pgfmathprintnumber{\\pgfmathresult}}")
	else
		ymin = min(ymin, mingain, 0.0)
		if typeof(ymax) != Void
			ymax -= ymin
			emsg = "ymax is smaller than smallest gain, 0, and specified ymin"
			ymax < ymin ? error(emsg) : nothing
		end

		# legendentries, styles must be indexable
		if legendentries == nothing
			legendentries = Array(Void, num_gp)
		end
		if styles == nothing
			styles = Array(Void, num_gp)
		end

		# Do we include the degrees
		if degrees
			xtl = "{\$\\pgfmathprintnumber{\\tick}^{\\circ}\$}"
		else
			xtl = nothing
		end

		plot_array = Array(Plots.Linear, num_gp)
		for i = 1:num_gp
			gp = gp_array[i]
			plot_array[i] = plotgains(gp.angles, gp.meangains, ymin, lastleg, legendentries[i], styles[i])
		end
		#xticklabel=$\pgfmathprintnumber{\tick}^\circ$
		pa = PolarAxis(plot_array, title=title, ymax=ymax, yticklabel="{\\pgfmathparse{$ymin+\\tick} \\pgfmathprintnumber{\\pgfmathresult}}", xticklabel=xtl)

	end

	# Return the polar axis object
	return pa

end

# Creates Plots.Linear object (from PGFPlots) with gains vs angles
# Can handle negative values, which radial plots normally cannot.
#
# ymin = minimum y (gain or radial) value. If it is positive, it is ignored.
#  If it is less than the minimum value of gains, also ignored.
function plotgains{T1<:Real,T2<:Real}(angles::Vector{T1}, gains::Vector{T2}, ymin::Real, lastleg::Bool, legendentry, style)

	# Make copies before we make some changes
	# Remember to shift gains by the minimum value to be plotted
	plot_gains = copy(gains) - ymin
	plot_angles = copy(angles)

	# Last point must be same as first point to complete the plot
	# If not, it will be missing a section between last point and first
	if (angles[1] != angles[end]) && lastleg
		push!(plot_angles, plot_angles[1])
		push!(plot_gains, plot_gains[1])
	end

	# Create a linear plot and return it
	#return Plots.Linear(plot_angles, plot_gains, mark="none", style="red,thick")
	return Plots.Linear(plot_angles, plot_gains, mark="none", legendentry=legendentry, style=style)
end

# Returns an array of plots
function plotsamples{T1<:Real,T2<:Real}(angles::Vector{T1}, samples::Vector{Vector{T2}}, ymin::Real)

	# Create an array of plots
	num_angles = length(angles)
	plot_array = Array(Plots.Linear, num_angles)

	# Create a linear plot for each sample
	for i = 1:num_angles
		plot_array[i] = Plots.Linear(angles[i]*ones(length(samples[i])), samples[i]-ymin, mark="x", style="blue,smooth")
	end

	# Return the array of plots
	return plot_array
end
end # module
