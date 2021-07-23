include("graphs.jl")
using DataFrames
using Plots
using Statistics
using HypothesisTests
using CSV
using Weave
using IJulia

function benchmark(exp::Experiment)
    name = exp.name
    workspace = exp.workspace

    if !ispath(workspace * "/notebooks")
        mkpath(workspace * "/notebooks")
    end

    convert_doc(
        "./src/benchmark/notebooks/overview.jmd",
        workspace * "/notebooks/overview.ipynb",
    )

    IJulia.jupyterlab(dir = workspace * "/notebooks")
end

function benchmark(path::String = "_results")
    df = DataFrames.DataFrame()
    for item in readdir(path)
        println(item)
        maindf = DataFrame(CSV.File(path * '/' * item))
        rename!(maindf, :iteration => :runtime, :size => :problem_size)
        df = vcat(df, maindf[:, [:algorithm, :runtime, :problem_size]])
    end
    resultpvalue(df)
    return benchmark(df)
end

function benchmark(traces::Array{Trace,1})
    df = tracestodataframe(traces)
    resultpvalue(df)
    return benchmark(df)
end

function tracestodataframe(traces::Array{Trace,1})
    result = DataFrames.DataFrame()
    for trace in traces
        push!(
            result,
            (
                algorithm = string(typeof(trace.algorithm)),
                runtime = trace.optimum[2],
                problem_size = length(trace.individual.problem),
            ),
        )
    end
    result
end

function jobstodataframe(jobs::Array{Job,1}) end

function benchmark(data::DataFrames.DataFrame)
    algorithms = keys(groupby(data, "algorithm"))
    plts = []

    append!(plts, [plot()])
    for algo in algorithms
        classical_0 = filter(row -> row["algorithm"] == algo[1], data)
        classical_0 = combine(groupby(classical_0, :problem_size), :runtime => mean)
        y = classical_0[!, :runtime_mean]
        x = classical_0[!, :problem_size]
        # v = classical_0[!,4]
        plot!(
            plts[end],
            x,
            y,
            fillalpha = 0.3,
            formatter = :plain,
            dpi = 300,
            fontfamily = "Times New Roman Bold",
            legend = :right,
            linewidth = 2,
            markersize = 3,
            markershape = :circle,
            linealpha = 0.5,
            size = (600, 300),
            label = algo,
        )
    end
    return plts[1]
end


function resultpvalue(df::DataFrames.DataFrame)
    algo = keys(groupby(df, :algorithm))
    problem_size = keys(groupby(df, :problem_size))

    for item in problem_size
        println("Problem Size: ", item["problem_size"])
        data2 = groupby(
            filter(row -> row["problem_size"] == item["problem_size"], df),
            :algorithm,
        )
        for item in data2
            for item2 in data2
                p_value = pvalue(MannWhitneyUTest(item["runtime"], item2["runtime"]))
                println(item[1][1], " vs ", item2[1][1], ", Pvalue = ", p_value)
            end
        end
    end
end


function runtimes(jobs::Array{Job,1})
    result = DataFrames.DataFrame()
    allowmissing!(result)
    for job in jobs
        trace = job.trace
        if !isnothing(trace)
            thing = (seed=trace.seed, algorithm=name(trace.algorithm), problem=string(trace.individual.problem), runtime=trace.optimum[2])
            push!(result, thing)
        end
    end

    for job in jobs
        trace = job.trace
        if !isnothing(trace)
            thing = (seed=trace.seed, algorithm=name(trace.algorithm))
            paramgroups = ( ProblemParam = deepparameters(trace.individual.problem), AlgorithmParams = deepparameters(trace.algorithm))
            for paramgroupkey in keys(paramgroups)
                for p in paramgroups[paramgroupkey]
                    label = Symbol(string(paramgroupkey )*"."*string(p[1]))
                    if string(label) in names(result)
                        result[result[:seed].==trace.seed,label] = p[2]
                    else
                        df = DataFrame([(seed=trace.seed, l=p[2])])
                        rename!(df,:l => label)
                        result = outerjoin(result, df, on = [:seed], makeunique=true )
                    end
                end
            end
        end
    end

    result
end

runtimes(exp::Experiment) = runtimes(exp.jobs)