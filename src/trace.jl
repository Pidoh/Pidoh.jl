using DataFrames
using CSV
using Random
using Dates

mutable struct Trace{T}
    seed::Any
    algorithm::AbstractAlgorithm
    individual::Union{Instance{T},Nothing}
    population::Union{Population{T},Nothing}
    rows::DataFrames.DataFrame
    optimum::NamedTuple{
        (:individual, :population, :iteration),
        Tuple{Union{Instance{T},Missing},Union{Population{T},Missing},Int64},
    }

    function Trace(
        algorithm::AbstractAlgorithm,
        seed::Int64 = ceil(Int64, time() * 10e6),
        rows::DataFrames.DataFrame = DataFrames.DataFrame(),
        optimum = (individual = missing, population = missing, iteration = -1);
        individual::Union{Instance{T},Nothing} = nothing,
        population::Union{Population{T},Nothing} = nothing,
    ) where {T}
        new{T}(seed, algorithm, individual, population, rows, optimum)
    end
end


#
# function store(db::dbEngine)
#     date_format = Dates.format(now(), "yymmddHHMMSS_s")
#     id = db.id
#     CSV.write("results/rows.csv", db.rows_df, append=true)
#     CSV.write("results/results.csv", db.results, append=true)
# end
#

function realparameters(algorithm::T) where {T<:AbstractAlgorithm}
    realfields = []
    for fieldname in fieldnames(typeof(algorithm))
        if typeof(getfield(algorithm, fieldname)) <: Real
            push!(realfields, fieldname)
        end
    end
    realfields
end

function storeresult(trace::Trace)
    date_format = Dates.format(now(), "yyyymmddHHMMSS_s")
    id = trace.seed

    result = Dict(
        "date" => date_format,
        "algorithm" => string(typeof(trace.algorithm)),
        "size" => length(trace.individual.problem),
        "iteration" => trace.optimum[2],
        "seed" => trace.seed,
    )

    for fieldname in realparameters(trace.algorithm)
        push!(result, (string(fieldname) => getfield(trace.algorithm, fieldname)))
    end

    result_df = DataFrame(result)

    # CSV.write("results/rows.csv", db.rows_df, append=true)
    csvfilename = string(typeof(trace.algorithm))
    writeheader = false
    rlock = Threads.Condition()
    lock(rlock)
    if !ispath("results")
        mkdir("results")
    end
    if !ispath("results/$csvfilename.csv")
        touch("results/$csvfilename.csv")
        writeheader = true
    end
    CSV.write("results/$csvfilename.csv", result_df, append = true, header = writeheader)
    unlock(rlock)
end

function info(trace::Trace, text, data)
    @debug text data...
end

function optimumfound(trace::Trace, x::Instance, iteration::Int64)
    storeresult(trace)
end

function record!(
    db::Trace{T},
    iteration::Int64,
    isoptimum::Bool = false;
    individual::Union{Instance{T},Missing} = missing,
    population::Union{Population{T},Missing} = missing,
) where {T}
    @assert ismissing(individual) ⊻ ismissing(population) "Either population or individual should be set" # TODO

    if !ismissing(population)
        fitness_value = fitness(population)
    else
        fitness_value = fitness(individual)
    end

    tuple = (iteration = iteration, fitness = fitness_value)
    info(db, "New row is inserted.", tuple)
    push!(db.rows, (iteration = iteration, fitness = fitness(individual)))
    db.optimum = (individual = individual, population = population, iteration = iteration)
    isoptimum && optimumfound(db, individual, iteration)
end

#
# function result(db::dbEngine, data)
#     @debug "Result" data...
#     push!(db.results, data)
# end
