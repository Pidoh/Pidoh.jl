abstract type AbstractEA <: AbstractAlgorithm end

using DataFrames

struct ea1pλwith2rates <: AbstractEA
    λ :: Integer
    stop :: AbstractStop
    function ea1pλwith2rates(;λ::Integer=10, stop::AbstractStop=fixedbudget(1000))
        new(λ, stop)
    end
end

function optimize(x, setting::ea1pλwith2rates)
    λ=setting.λ
    trace = Trace(setting, x)
    n=length(x)
    # bitrand returns a random bit string.
    r = 2

    for iter ∈ 1:niterations(setting.stop)
        α = copy(x)
        rα = r
        for i in 1:λ
            if i ≤ λ/2
                ry = r/(2n)
                y = mutation(x, UniformlyIndependentMutation(ry))
            else
                ry = 2r/n
                y = mutation(x, UniformlyIndependentMutation(ry))
            end

            if fitness(y) ≥ fitness(α)
                α = y
                rα = ry
            end
        end

        # The second condition is for implementing "breaking ties randomly".
        if fitness(α) ≥ fitness(x)
            if fitness(α) > fitness(x)
                record(trace, α, iter, isoptimum(α))
            end
            x = α

            if isoptimum(x)
                return trace
            end
        end

        if rand() < 0.5
            r = rα
        else
            r = if (rand() < 0.5)  r = r/2  else  r = 2r  end
        end
        r = min(max(r,2),n/4)
    end
    trace
end

struct ea1p1 <: AbstractEA
    mutation :: Mutation
    stop :: AbstractStop
    function ea1p1(; stop::AbstractStop=fixedbudget(1000), mutation::Mutation=UniformlyIndependentMutation(0.5))
        new(mutation, stop)
    end
end

function optimize(x, setting::ea1p1)
    trace = Trace(setting, x)
    n=length(x)
    # bitrand returns a random bit string.

    for iter ∈ 1:niterations(setting.stop)

        y = mutation(x, setting.mutation)

        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) ≥ fitness(x)
            if fitness(y) > fitness(x)
                record(trace, y, iter, isoptimum(y))
            end
            x = y

            if isoptimum(x)
                return trace
            end
        end
    end
    trace
end

struct ea1p1SD <: AbstractEA
    R :: Real
    stop :: AbstractStop
    thresholds :: Array
    function ea1p1SD(;R::Real=1, stop::AbstractStop=fixedbudget(1000), thresholds=[typemax(Int) for _ in 1:10])
        new(R, stop, thresholds)
    end
end



SDCounter(n::Integer, r::Real, R::Real) = (n/r)^r*(n/(n-r))^(n-r)*log(Base.MathConstants.e*n*R)
SDCounterEstimation(n::Integer, r::Real, R::Real) = (Base.MathConstants.e*n/r)^r*log(Base.MathConstants.e*n*R)

function thresholds(generator::Function, n::Integer, R::Real)
    thresh = []
    for r in 1:ceil(Int,n/2)
        val = generator(n , r, R)
        push!(thresh, val)
        if val >= typemax(Int)/n
            break
        end
    end
    thresh
end

function optimize(x, setting::ea1p1SD)
    trace = Trace(setting, x)
    n=length(x)
    thresholds = setting.thresholds
    r = 1
    u = 0
    for iter ∈ 1:niterations(setting.stop)
        y = mutation(x, UniformlyIndependentMutation(r//n))
        u += 1
        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) > fitness(x)
            x = y
            u = 0
            r = 1
            println("New rate", r)
            println(fitness(x), " in iteration= ", iter)
            record(trace, y, iter, isoptimum(y))
            if isoptimum(x)
                # println("The Optimum is found.")
                return trace
            end
        elseif fitness(y) == fitness(x) && r == 1
            x = y
        end

        if u > thresholds[r]
            r = min(r+1, ceil(Int,n/2))
            println("New rate", r)
            u = 0
        end
    end
    trace
end

struct ea1pλSASD <: AbstractEA
    R :: Real
    λ :: Integer
    stop :: AbstractStop
    thresholds :: Array
    function ea1pλSASD(;R::Real=1, λ:: Integer = 10, stop::AbstractStop=fixedbudget(1000), thresholds=[typemax(Int) for _ in 1:10])
        new(R, λ, stop, thresholds)
    end
end

function optimize(x, setting::ea1pλSASD)
    trace = Trace(setting, x)
    n=length(x)
    thresholds = setting.thresholds
    λ=setting.λ
    r_init = 2
    r = r_init
    u = 0
    g = false

    for iter ∈ 1:niterations(setting.stop)
        u += 1
        if g == false
            y = copy(x)
            ry = r
            for i in 1:λ
                if i ≤ λ/2
                    rα = r/(2n)
                    α = mutation(x, UniformlyIndependentMutation(rα))
                else
                    rα = 2r/n
                    α = mutation(x, UniformlyIndependentMutation(rα))
                end

                if fitness(α) ≥ fitness(y)
                    y = α
                    ry = rα
                end
            end
            if fitness(y) ≥ fitness(x)

                if fitness(y) > fitness(x)
                    println("New rate $r in $g")
                    record(trace, y, iter, isoptimum(y))
                end
                x = y

                if isoptimum(x)
                    return trace
                end
            end

            if rand() < 0.5
                r = ry
            else
                r = if (rand() < 0.5)  r = r/2  else  r = 2r  end
            end
            r = floor(Int,min(max(r,2),n/4))

            if u > thresholds[r]/λ
                r = 2
                println("New rate $r in $g")
                println("STAG detection.")
                g = true
                u = 0
            end

        else
            y = copy(x)
            for i in 1:λ
                α = mutation(x, UniformlyIndependentMutation(r/n))
                if fitness(α) ≥ fitness(y)
                    y = α
                end
            end
            # The second condition is for implementing "breaking ties randomly".
            if fitness(y) > fitness(x)
                x = y
                r = r_init
                println("New rate $r in $g")
                g = false
                u = 0
                record(trace, y, iter, isoptimum(y))
                if isoptimum(x)
                    # println("The Optimum is found.")
                    return trace
                end
            end

            if u > thresholds[r]/λ
                r = min(r+1, ceil(Int,n/2))
                println("New rate $r in $g")
                u = 0
            end
        end
    end
    trace
end



struct RLSSDstar <: AbstractEA
    R :: Real
    stop :: AbstractStop
    thresholds :: Array
    function RLSSDstar(;R::Real=1, stop::AbstractStop=fixedbudget(1000), thresholds=[typemax(Int) for _ in 1:10])
        new(R, stop, thresholds)
    end
end



RLSSDCounter(n::Integer, r::Real, R::Real) = binomial(n, r)*log(R)

function optimize(x, setting::RLSSDstar)
    trace = Trace(setting, x)
    n=length(x)
    thresholds = setting.thresholds
    r = 1
    s = 1
    u = 0
    for iter ∈ 1:niterations(setting.stop)
        y = mutation(x, KBitFlip(s))
        u += 1
        # The second condition is for implementing "breaking ties randomly".
        if fitness(y) > fitness(x)
            x = y
            u = 0
            r = 1
            s = 1
            println("New rate", s)
            println(fitness(x), " in iteration= ", iter)
            record(trace, y, iter, isoptimum(y))
            if isoptimum(x)
                return trace
            end
        elseif fitness(y) == fitness(x) && s == 1
            x = y
        end

        if u > thresholds[s]
            if s == 1
                if r < n/2
                    r = r+1
                else
                    r = n
                end
                s = r
            else
                s = s-1
            end
            println("New rate", s)
            u = 0
        end
    end
    trace
end
