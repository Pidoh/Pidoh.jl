abstract type AbstractSimulatedAnnealing <: AbstractAlgorithm end
abstract type AbstractCooling end


struct FixedCooling <: AbstractCooling
    temperature::Float64
    function FixedCooling(
        temperature::Float64=1.0,
    )
        new(temperature)
    end
end

function temperature(cooling::FixedCooling, iter::Int64)
    return cooling.temperature
end


struct sa <: AbstractSimulatedAnnealing
    cooling::AbstractCooling
    stop::AbstractStop
    name::LaTeXString
    function sa(cooling::AbstractCooling;
        stop::AbstractStop = FixedBudget(10^10),
        name::LaTeXString=L"Simulated-Annealing",
    )
        new(cooling, stop, name)
    end
end

function optimize(x, setting::sa)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)

    for iter ∈ 1:niterations(setting.stop)
        α = temperature(setting.cooling, iter)
        y = mutation(x, KBitFlip(1))
        Δ =  fitness(y) - fitness(x)

        if Δ ≥ 0
            if Δ > 0
                record(trace, y, iter, isoptimum(y))
            end
            x = y
            if isoptimum(x)
                return trace
            end
        elseif rand() ≤ α^(Δ)
            record(trace, y, iter, isoptimum(y))
            x = y
        end
    end
    trace
end
