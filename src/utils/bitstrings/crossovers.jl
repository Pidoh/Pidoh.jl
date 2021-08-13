using StatsBase

abstract type AbstractCrossover end

function mate(population::Population{T}) where {T}
    population_size = length(population.solutions)
    pairs::Vector{Pair{Instance{T},Instance{T}}} = []

    for i ∈ 1:population_size
        first_solution = population.solutions[i]
        second_solution =
            population.solutions[sample(filter(x -> x ≠ i, 1:population_size))]

        push!(pairs, first_solution => second_solution)
    end

    pairs
end

struct OnePointCrossover <: AbstractCrossover
    crossover_probability::Float64
end

function crossover(
    population::Population{BitArray},
    operator::OnePointCrossover,
)::Population{BitArray}
    @assert 0 ≤ operator.crossover_probability ≤ 1

    mates = mate(population)
    selected_mates = rand(mates, 10)

    children::Vector{BitArray} = []

    for i ∈ 1:length(selected_mates)
        parents::Pair{Instance{BitArray},Instance{BitArray}} = selected_mates[i]
        solution_size = length(parents.first)

        cut_point = rand(2:(solution_size-1))

        push!(
            children,
            vcat(
                parents.first.individual[1:(cut_point-1)],
                parents.second.individual[cut_point:solution_size],
            ),
        )
        push!(
            children,
            vcat(
                parents.second.individual[1:(cut_point-1)],
                parents.first.individual[cut_point:solution_size],
            ),
        )
    end

    Population(children, population.problem)
end
