
import Base: run
# struct Experiment{T <: AbstractAlgorithm, S <: Instance}
#     algorithms::Array{T,1}
#     initials::Array{S,1}
#     count::Integer
#
#     function Experiment(
#         algorithms::Array{T,1},
#         initials::Array{S,1};
#         count::Integer=-1 ) where {T <: AbstractAlgorithm, S <: Instance}
#         if length(algorithms) ≠ length(initials)
#             error("The number of algorithms is not match with the number of initials.")
#         end
#         if count == -1
#             count = length(algorithms)
#         end
#         new{typeof(algorithms[1]), typeof(initials[1])}(algorithms, initials, count)
#     end
# end

struct Experiment
    name :: String
    algorithms
    initials
    count::Integer
    workspace::String

    function Experiment(name::String, algorithms, initials; count::Integer=-1 )
        if length(algorithms) ≠ length(initials)
            error("The number of algorithms is not match with the number of initials.")
        end
        if count == -1
            count = length(algorithms)
        end
        date = Dates.format(now(), "mmddHHMMSS")
        workspace = "_workspace/$(name)_"*date
        new(name, algorithms, initials, count, workspace)
    end
end

include("engines.jl")

function run(exp::Experiment)
    traces::Array{Trace,1}=[]
    for i in 1:exp.count
        trace = optimize(exp.initials[i], exp.algorithms[i])
        push!(traces, trace)
    end
    traces
end


function run(exp::Experiment, hpc::HPC)
    createworkspace(exp, hpc)
    createworkspaceinserver(exp,hpc)
    submitjob(exp, hpc)
    println(exp.workspace)
end
