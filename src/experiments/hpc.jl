using Mustache
using Suppressor
using JLD
include("_template.jl")

struct HPC
    server::String
    user::String
    core::Integer
end


sshcommand(hpc::HPC, command::String) = @capture_out run(`ssh $(hpc.user)"@"$(hpc.server) "source /etc/profile;" $command`)

function createworkspace(exp::Experiment, hpc::HPC)
    name = exp.name
    workspace = exp.workspace

    if ! ispath(workspace)
        mkpath(workspace)
    else
        rm(workspace, recursive=true)
        mkpath(workspace)
    end

    # Create job.sh
    createtasktemplate(exp, hpc)

    #Create julia code
    save(workspace*"/data.jld", "Experiment", exp)
    cp("src/experiments/_main.jl", workspace*"/main.jl")
    cp("Project.toml", workspace*"/Project.toml")
end

function createworkspaceinserver(exp::Experiment, hpc::HPC)
    name = exp.name
    @info "Creating a copy of the project in $name direcotry of your folder in server ..."
    workspace = exp.workspace
    sshcommand(hpc, "mkdir -p $workspace")
    run(`scp -r src $(hpc.user)"@"$(hpc.server)":~/"$workspace`)
    run(`scp -r $workspace"/." $(hpc.user)"@"$(hpc.server)":~/"$workspace`)
    # sshCommand("mkdir results/$name")
end

function removeWorkSpaceInServer(name)
    sshCommand("rm -rf julia/$name")
end

function removeWorkSpaceDataServer(name)
    sshCommand("rm -rf results/$name")
end

function createtasktemplate(exp::Experiment, hpc::HPC)
    home_directory = @capture_out run(`ssh "amraj@login2.hpc.dtu.dk" 'pwd'`)
    home_directory = home_directory[1:end-1] # To remove '\n'
    workspace = exp.workspace
    tpl = template()
    data= Dict(
    "name" => exp.name,
    "workspace" => "$home_directory/$workspace",
    "cores" => hpc.core,
    "cluster" => "compute",
    "command" => "julia $home_directory/$workspace/main.jl --project=$home_directory/$workspace"
    )
    rendered = render(tpl, data)
    open("$workspace/job.sh", "w") do io
           write(io, rendered)
       end;
end


function submitjob(exp::Experiment, hpc::HPC)
    tasknumber = 40
    workspace = exp.workspace
    bash_file = "job.sh"
    thejob = "cd $workspace && for i in {1..$tasknumber}; do bsub < $bash_file ; sleep 1; done"
    @info sshcommand(hpc, thejob)
end

function submitTask(workspace, taskfile, tasknumber=40)
    home_directory = @capture_out run(`ssh "amraj@login2.hpc.dtu.dk" 'pwd'`)
    home_directory = home_directory[1:end-1] # To remove '\n'
    command = "$home_directory/julia/$workspace/$taskfile"
    bash_file = "$home_directory/julia/$workspace/server/templates/$workspace.sh"
    createTaskTemplate(workspace, command)
    createWorkSpaceInServer(workspace) #Uncomment to work
    thejob = "for i in {1..$tasknumber}; do bsub < $bash_file ; sleep 1; done"
    @info sshCommand(thejob)
    # @info @capture_out run(`ssh amraj@login2.hpc.dtu.dk $thejob`)
end

function fetchresults(exp::Experiment, hpc::HPC)
    workspace = exp.workspace
    run(`scp -r "amraj@login2.hpc.dtu.dk:~/"$workspace/_results $workspace/_results`)
    @info "The results folder is downloaded in $workspace/_results."
end

# taskStatus() = @info sshCommand("bstat compute")
#
# cluster(hpc::HPC) = @info sshcommand(hpc, "classstat")
# cluster(hpc::HPC, class::String) = @info sshcommand(hpc, "classstat $(class)")
#
# submitTask("asymmetric", "examples/asymmetric.jl", 10)
#
# removeWorkSpaceInServer("asymmetric")
# removeWorkSpaceDataServer("asymmetric")
#
# fetchResult("asymmetric")
