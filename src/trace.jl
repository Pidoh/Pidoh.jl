using DataFrames
using CSV
using Random
using Dates

mutable struct Trace
    seed
    algorithm :: AbstractAlgorithm
    individual :: Instance
    rows:: DataFrames.DataFrame

    optimum:: NamedTuple{(:individual,:iteration),Tuple{Any, Int64}}

    function Trace(
            algorithm::AbstractAlgorithm,
            individual::Instance;
            seed::Int64=ceil(Int64, time()*10e6),
            rows::DataFrames.DataFrame=DataFrames.DataFrame(),
            optimum=(individual=missing, iteration=-1))
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

function realparameters(algorithm::T) where {T<: AbstractAlgorithm}
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

    result = Dict("seed"=>trace.seed,"iteration"=>trace.optimum[2], "date"=>date_format)

    for fieldname in realparameters(trace.algorithm)
        push!(result, (string(fieldname)=>getfield(trace.algorithm, fieldname)))
    end

    result_df = DataFrame(result)

    # CSV.write("results/rows.csv", db.rows_df, append=true)
    csvfilename = string(typeof(trace.algorithm))
    writeheader = false
    if ! ispath("_results")
        mkdir("_results")
    end
    if ! ispath("_results/$csvfilename.csv")
        touch("_results/$csvfilename.csv")
        writeheader = true
    end
    CSV.write("_results/$csvfilename.csv", result_df, append=true, writeheader=writeheader)
end

function info(trace::Trace, text, data)
 @debug text data...
end

function optimumfound(trace::Trace, x::Instance, iteration::Int64)
    trace.optimum = (individual=x.individual, iteration=iteration)
    storeresult(trace)
end

function record(db::Trace, x::Instance, iteration::Int64, isoptimum::Bool = false)
    tuple = (iteration=iteration, fitness=fitness(x))
    info(db, "New row is inserted.", tuple )
    push!(db.rows, (iteration=iteration, fitness=fitness(x)))

    isoptimum && optimumfound(db, x, iteration)
end

#
# function result(db::dbEngine, data)
#     @debug "Result" data...
#     push!(db.results, data)
# end
