using DataFrames
using CSV
using Random
using Dates

mutable struct Trace
    seed::Any
    algorithm::AbstractAlgorithm
    individual::Instance
    rows::DataFrames.DataFrame
    optimum::NamedTuple{(:individual, :iteration),Tuple{Any,Integer}}

    function Trace(
        algorithm::AbstractAlgorithm,
        individual::Instance;
        seed::Integer = ceil(Integer, (time() * 10e6) % typemax(Int)),
        rows::DataFrames.DataFrame = DataFrames.DataFrame(),
        optimum = (individual = missing, iteration = -1),
    )
        new(seed, algorithm, individual, rows, optimum)
    end
end


function deepparameters(object)
    allfields = Dict()
    for fieldname in fieldnames(typeof(object))
        if typeof(getfield(object, fieldname)) <: Real
            push!(allfields, (fieldname => getfield(object, fieldname)))
        else
            subfield = getfield(object, fieldname)
            push!(allfields, (fieldname => string(getfield(object, fieldname))))
            for key_value in deepparameters(subfield)
                push!(
                    allfields,
                    (
                        Symbol(string(fieldname) * "_" * string(key_value[1])) =>
                            key_value[2]
                    ),
                )
            end
        end
    end
    allfields
end


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

function optimumfound(trace::Trace, x::Instance, iteration::Integer)
    storeresult(trace)
end

function record(db::Trace, x::Instance, iteration::Integer, isoptimum::Bool = false)
    tuple = (iteration = iteration, fitness = fitness(x))
    info(db, "New row is inserted.", tuple)
    push!(db.rows, (iteration = iteration, fitness = fitness(x)))
    db.optimum = (individual = x.individual, iteration = iteration)
    isoptimum && optimumfound(db, x, iteration)
end
