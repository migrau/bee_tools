using Compose
using Color
using Distributions

# Random binary code
d = DiscreteUniform(1, 2)

# Implements a code similar to the code used in Wichmann2014
# code: Integer vector corresponding to the colors indices
# r1: radius of the inner circle
# r2: radius of the outer circle
# r3: radius of the border circle
# [cx], [cy]: center coordinates of the circle
# [colors]: Vector of colors to choose from, defaults to black and white
# [lw]: thickness of the border between inner circle and code segments
function berlin_code(code, r1, r2, r3 = 1.0;
                     cx = .5, cy = .5, 
                     colors = ["white", "black"], 
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
        color = colors[id]

        c = compose(
              context(rotation = Rotation(θ))
              , seg
              #, segment(cx, cy, r1, r2, θ, θ+step)
              , stroke(color)
              , fill(color))

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

# Calculates a point on the circle given by (cx, cy, r),
# according to the angle θ in radians
function point_on_circle(cx, cy, r, θ)
    x = cx + r * cos(θ)
    y = cy + r * sin(θ)
    (x, y)
end

# Draws a code segment. Currently the circular borders are not perfect.
# The control point AB and CD should lay outside the circle
# cx, cy: center point of both circles
# r1: radius of the inner circle
# r2: radius of the outer circle
# α: starting angle
# ω: target angle
function segment(cx, cy, r1, r2, α, ω)
    A = point_on_circle(cx, cy, r1, α)
    AB = point_on_circle(cx, cy, r1, (α + ω)/2)
    B = point_on_circle(cx, cy, r1, ω)
    
    C = point_on_circle(cx, cy, r2, ω)
    CD = point_on_circle(cx, cy, r2, (α + ω)/2)
    D = point_on_circle(cx, cy, r2, α)
    
    # Uses a path to draw the segments to be able to fill it
    compose(context(), 
        path([
            :M, A..., # Move (not draw) to position A
            :C, AB..., AB..., B..., # Draw a CubicSpline from A to B with control AB
            :L, C..., # Line to C
            :C, CD..., CD..., D..., # Draw a CubicSpline from D to C with control DC
            :Z])) # Close the path with a line to A
end

# Draws a full circle (cx, cy, r) and then clips it to a half circle.
# A,B,C,D give the rectangle of the area of interest,
# The extrema are used to prevent over-clipping
function half_circle(cx, cy, r)
    A = (0, cy)
    B = (1, cy)
    C = (1, 1)
    D = (0, 1)
    compose(context(), circle(cx, cy, r), clip(A, B, C, D))
end

# Create a pie with a center at cx, cy, and with radius r,
# inner angle is θ
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