# represents a rectangle
struct ℛ{T}
  left::T
  bottom::T
  width::T
  height::T
end

left(r::ℛ) = r.left
right(r::ℛ{<:Int}) = r.left + r.width - 1
right(r::ℛ{<:AbstractFloat}) = r.left + r.width
width(r::ℛ) = r.width
bottom(r::ℛ) = r.bottom
top(r::ℛ{<:Int}) = r.bottom + r.height - 1
top(r::ℛ{<:AbstractFloat}) = r.bottom + r.height
height(r::ℛ) = r.height
aspectratio(r::ℛ) = r.width / r.height

left(r::Observable) = left(r[])
right(r::Observable) = right(r[])
width(r::Observable) = width(r[])
bottom(r::Observable) = bottom(r[])
top(r::Observable) = top(r[])
height(r::Observable) = height(r[])
aspectratio(r::Observable) = aspectratio(r[])

function ℛ(r::ℛ; left=missing, bottom=missing, width=missing, height=missing)
  left === missing && (left = r.left)
  bottom === missing && (bottom = r.bottom)
  width === missing && (width = r.width)
  height === missing && (height = r.height)
  ℛ(left, bottom, width, height)
end

ℛ(r::Observable; kwargs...) = ℛ(r[]; kwargs...)

abstract type Canvas end

Base.@kwdef struct DataSource
  generate!::Function
  xyrect::ℛ{Float64}       # default extents in data coordinates
  data = missing
  rubberband::Bool = true
  clim::Tuple = (0.0, 1.0) # default color limits
  xmin::Float64 = -Inf64
  xmax::Float64 = Inf64
  ymin::Float64 = -Inf64
  ymax::Float64 = Inf64
  cmin::Float64 = -Inf64
  cmax::Float64 = Inf64
  xpan::Bool = true
  ypan::Bool = true
  cpan::Bool = true
  xzoom::Bool = true
  yzoom::Bool = true
  czoom::Bool = true
  xylock::Bool = false
  minwidth::Float64 = 0
  maxwidth::Float64 = Inf64
  minheight::Float64 = 0
  maxheight::Float64 = Inf64
end

Base.@kwdef struct Viz
  scene::Scene
  ijrect::Observable{ℛ{Int}}       # size of window in pixels
  selrect::Observable{ℛ{Int}}      # last selected rectangle
  children::Vector{Canvas}
end

Base.@kwdef struct HeatmapCanvas <: Canvas
  parent::Viz
  ijhome::Observable{ℛ{Int}}       # home location for canvas in pixels
  ijrect::Observable{ℛ{Int}}       # current location for canvas in pixels
  xyrect::Observable{ℛ{Float64}}   # canvas extents in data coordinates
  clim::Observable{Tuple}
  buf::Observable{Matrix{Float32}}
  datasrc::DataSource
  dirty::Observable{Bool}
  task::Ref{Task}
end

Base.@kwdef struct ScatterCanvas <: Canvas
  parent::Viz
  ijhome::Observable{ℛ{Int}}       # home location for canvas in pixels
  ijrect::Observable{ℛ{Int}}       # current location for canvas in pixels
  xyrect::Observable{ℛ{Float64}}   # canvas extents in data coordinates
  buf::Observable{Vector{Point2f}}
  datasrc::DataSource
  dirty::Observable{Bool}
  task::Ref{Task}
end

Base.@kwdef struct LineCanvas <: Canvas
  parent::Viz
  ijhome::Observable{ℛ{Int}}       # home location for canvas in pixels
  ijrect::Observable{ℛ{Int}}       # current location for canvas in pixels
  xyrect::Observable{ℛ{Float64}}   # canvas extents in data coordinates
  buf::Observable{Vector{Point2f}}
  datasrc::DataSource
  dirty::Observable{Bool}
  task::Ref{Task}
end

Base.show(io::IO, x::Viz) = println(io, typeof(x))
Base.show(io::IO, x::Canvas) = println(io, typeof(x))
