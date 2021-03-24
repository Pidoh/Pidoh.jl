using DataFrames
using CSV
using Random
using Dates

mutable struct Trace
    seed::Any
    algorithm::AbstractAlgorithm
    individual::Instance
    rows::DataFrames.DataFrame
    optimum::NamedTuple{(:individual, :iteration),Tuple{Any,Int64}}

    function Trace(
        algorithm::AbstractAlgorithm,
        individual::Instance;
        seed::Int64 = ceil(Int64, time() * 10e6),
        rows::DataFrames.DataFrame = DataFrames.DataFrame(),
        optimum = (individual = missing, iteration = -1),
    )
        new(seed, algorithm, individual, rows, optimum)
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

function record(db::Trace, x::Instance, iteration::Int64, isoptimum::Bool = false)
    tuple = (iteration = iteration, fitness = fitness(x))
    info(db, "New row is inserted.", tuple)
    push!(db.rows, (iteration = iteration, fitness = fitness(x)))
    db.optimum = (individual = x.individual, iteration = iteration)
    isoptimum && optimumfound(db, x, iteration)
end

#
# function result(db::dbEngine, data)
#     @debug "Result" data...
#     push!(db.results, data)
# end
