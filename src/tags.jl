using Docile

module Tags

export create_tag

using Compose
using Color

@doc """
Implements a tag scheme similar to the tags used in Wichmann2014
code: Integer vector corresponding to the colours indices
r1: radius of the inner circle
r2: radius of the outer circle
r3: radius of the border circle
[cx], [cy]: enter coordinates of the circle
[colours]: Vector of colours to choose from, defaults to white and black
[lw]: thickness of the border between inner circle and code segments
""" ->
function create_tag(code, r1, r2, r3 = 1.0;
                     cx = .5, cy = .5,
                     colours = ["white", "black"],
                     lw = 4pt)
    # Number of code segments necessary
    n = length(code)

    # Angular step size
    step = 2π/n

    contexts = Context[]
    seg = pie(cx, cy, r2, step)

    # Current angle starting at 0 ending at 2π
    θ = 0.0

    for id in code
        colour = colours[id]

        c = compose(
              context(rotation = Rotation(θ))
              , seg
              #, segment(cx, cy, r1, r2, θ, θ+step)
              , stroke(colour)
              , fill(colour))

        push!(contexts, c)
        
        θ += step # Update current angle
    end

    # Lower circle
    lower = compose(
                context()
                , half_circle(cx, cy, r1)
                , stroke("white")
                , fill("black")
                , linewidth(lw))
    
    # Upper circle
    upper = compose(
                context(rotation = Rotation(π))
                , half_circle(cx, cy, r1)
                , stroke("black")
                , fill("white")
                , linewidth(lw))

    # Border
    border = compose(
                context()
                , circle(cx, cy, r3)
                , stroke("white")
                , fill("white"))
    # join together all segments end the inner circle
    compose(context(), lower, upper, contexts, border)
end

@doc """
Calculates a point on the circle given by (cx, cy, r),
according to the angle θ in radians
""" ->
function point_on_circle(cx, cy, r, θ)
    x = cx + r * cos(θ)
    y = cy + r * sin(θ)
    (x, y)
end

@doc """
Draws a full circle and clips it to a half circle.
cx, cy: centre coordinates of the circle
r: radius of the circle
""" ->
function half_circle(cx, cy, r)
    # the points A,B,C,D give the rectangle of the area of interest,
    # The extrema are used to prevent over-clipping
    A = (0, cy)
    B = (1, cy)
    C = (1, 1)
    D = (0, 1)
    compose(context(), circle(cx, cy, r), clip(A, B, C, D))
end

@doc """
Create a pie of a circle
cx, cy : centre
r: radius
θ: inner angle
""" ->
function pie(cx, cy, r, θ)
    c = r*tan(θ)

    # Create the points, right angle ABC
    A = (cx, cy)
    B = (A[1] + r, A[2])
    C = (B[1], B[2] - c)

    compose(context(),
    circle(A..., .4),
    clip(A, B, C)
    )
end

end # Module
