using JLD2
using SparseArrays
using LightGraphs, SimpleWeightedGraphs
using DataFrames
using Dates
using Random
using UUIDs
import Base: run, length

@enum JobStatus pending assigned running finished

mutable struct Job
    jobid::UUID
    algorithm::AbstractAlgorithm
    instance::Instance
    trace::Union{Trace,Nothing}
    status::JobStatus
    startdate::Union{DateTime,Nothing}
    finishdate::Union{DateTime,Nothing}
    threadid::Union{Integer,Nothing}
    serverid::Union{Integer,Nothing}


    function Job(
        algorithm::AbstractAlgorithm,
        instance::Instance;
        jobid::UUID = uuid4(),
        trace::Union{Trace,Nothing} = nothing,
        status::JobStatus = pending,
        startdate::Union{DateTime,Nothing} = nothing,
        finishdate::Union{DateTime,Nothing} = nothing,
        threadid::Union{Integer,Nothing} = nothing,
        serverid::Union{Integer,Nothing} = nothing,
    )
        new(jobid, algorithm, instance, trace, status, startdate, finishdate, serverid)
    end
end


struct Experiment
    name::String
    jobs::Array{Job,1}
    workspace::String
    save::Bool

    function Experiment(
        name::String,
        algorithms::Array{T,1},
        instances::Array{Instance,1};
        save::Bool = true,
        repeat::Integer = 1,
    ) where {T<:AbstractAlgorithm}
        if length(algorithms) ≠ length(instances)
            error("The number of algorithms is not match with the number of initials.")
        end

        jobs =
            [Job(algorithms[i], instances[i]) for j = 1:repeat for i = 1:length(algorithms)]

        if save
            if !ispath("_workspace/$(name)")
                workspace = "_workspace/$(name)"
            elseif !ispath("_workspace/$(name)_" * Dates.format(now(), "SS"))

                workspace = "_workspace/$(name)_" * Dates.format(now(), "SS")
            else
                workspace = "_workspace/$(name)_" * Dates.format(now(), "mmddHHMMSS")
            end
        else
            workspace = "@memory/$(name)"
        end
        obj = new(name, jobs, workspace, save)

        if save
            mkworkspace(obj)
        end
        return obj
    end
end

length(exp::Experiment) = length(exp.jobs)

function mergeexperiments(path::String)
    jld2files = []
    for (root, dirs, files) in walkdir(path)
        files = joinpath.(root, files)
        for ff in files
            # println(ff)
            if endswith(ff, "jld2")
                push!(jld2files, ff)
            end
        end
    end
    println(jld2files)
    experiments = loadexperiment.(jld2files)
    experiment = experiments[1]
    for jobindex = 1:length(experiment.jobs)
        job = experiment.jobs[jobindex]
        if job.status != finished
            println(job.jobid)
            for exp in experiments[2:end]
                jj = findfirst(
                    row -> row.jobid == job.jobid && row.status == finished,
                    exp.jobs,
                )
                if !isnothing(jj)
                    jobcandidate = exp.jobs[jj]
                    println(jobcandidate.serverid, jobcandidate.status)
                    experiment.jobs[jobindex] = exp.jobs[jj]
                    break
                end
            end
        end
    end
    date = Dates.format(now(), "mmddHHMMSSs")
    saveexperiment(path * "/merged_data-$(date).jld2", experiment)
    experiment
end


function loadexperiment(path::String)
    jldopen(path) do file
        return file["experiment"]
    end
end

function saveexperiment(path::String, experiment::Experiment)
    jldopen(path, "w") do file
        return file["experiment"] = experiment
    end
end

include("engines.jl")

function run(job::Job)
    dateformat = "HH:MM:SS dd u y"
    job.startdate = now()
    job.status = running
    job.threadid = Threads.threadid()
    job.trace = optimize(job.instance, job.algorithm)
    job.status = finished
    job.finishdate = now()
    @info("The job finished.")
end

function run(exp::Experiment, serverid::Integer = 0, shuffle::Bool = true)
    queue = collect(Integer, 1:length(exp))
    if shuffle
        shuffle!(queue)
    end
    @info("Server $serverid is started to work.")
    for i in queue
        job = exp.jobs[i]
        @info("Job $i.")
        if serverid == 0 || job.serverid == serverid
            if job.status == pending
                @info("Job $i is processing in server $serverid.")
                job.status = assigned
                run(job)
            end
        end
    end
    if exp.save
        updateworkspace(exp)
    end
    exp
end


function run(exp::Experiment, hpc::HPC)
    for job in exp.jobs
        job.serverid = rand(1:hpc.jobs)
    end
    if exp.save
        updateworkspace(exp)
    end

    createtasktemplate(exp, hpc)
    createworkspaceinserver(exp, hpc)
    submitjob(exp, hpc)
    println(exp.workspace)
    return hpc
end



function mkworkspace(exp::Experiment)
    name = exp.name
    workspace = exp.workspace

    if !ispath(workspace)
        mkpath(workspace)
    end
    if !ispath("$(workspace)/results")
        mkpath("$(workspace)/results")
    end

    # save(workspace*"/data.jld2", Dict("experiment"=>exp))
    # jldopen(workspace*"/data.jld2", "w") do file
    #     file["experiment"] = exp
    # end
    saveexperiment(workspace * "/data.jld2", exp)

    # save(workspace*"/results/data-initial.jld2", Dict("experiment"=>exp))
    # jldopen(workspace*"/results/data-initial.jld2", "w") do file
    #     file["experiment"] = exp
    # end
    saveexperiment(workspace * "/results/data-initial.jld2", exp)

    cp("src/experiments/_main.jl", workspace * "/main.jl")
    cp("Project.toml", workspace * "/Project.toml")
end

function updateworkspace(exp::Experiment)
    name = exp.name
    workspace = exp.workspace
    date = Dates.format(now(), "mmddHHMMSSs")
    if !ispath(workspace)
        workspace = "."
    end

    # FileIO.save(workspace*"/data.jld2", Dict("experiment"=>exp))
    # jldopen(workspace*"/data.jld2", "w") do file
    #     file["experiment"] = exp
    # end
    saveexperiment(workspace * "/data.jld2", exp)
    # FileIO.save(workspace*"/results/data-$(date).jld2", Dict("experiment"=>exp))
    # jldopen(workspace*"/results/data-$(date).jld2", "w") do file
    #     file["experiment"] = exp
    # end
    saveexperiment(workspace * "/results/data-$(date).jld2", exp)
end


function threadsdistribution(exp::Experiment)
    for job in exp.jobs
        println(job.threadid)
    end
end
