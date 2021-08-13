using LaTeXStrings

abstract type AbstractGA <: AbstractAlgorithm end

struct ga <: AbstractGA
    stop::AbstractStop
    name::LaTeXString
    selection::AbstractSelection
    mutation::Union{AbstractMutation,Nothing}
    crossover::Union{AbstractCrossover,Nothing}
    function ga(;
        stop::AbstractStop,
        name::LaTeXString,
        selection::AbstractSelection,
        mutation::Union{AbstractMutation,Nothing} = nothing,
        crossover::Union{AbstractCrossover,Nothing} = nothing,
    )
        new(stop, name, selection, mutation, crossover)
    end
end

function optimize(population::Population, setting::ga)
    trace = Trace(setting, population = population)
    println(21)

    for iter ∈ 1:niterations(setting.stop)
        println(21)
        population = select(population, setting.selection)

        if setting.crossover !== nothing
            population = crossover(population, setting.crossover)
        end

        if setting.mutation !== nothing
            population = mutation(population, setting.mutation)
        end

        record!(trace, iter, hasoptimum(population), population = population)

        if hasoptimum(population)
            return trace
        end
    end

    trace
end
