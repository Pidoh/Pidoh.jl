using Mustache
using Suppressor
include("_template.jl")

struct HPC
    server::String
    user::String
    cores::Integer
    jobs::Integer
    function HPC(server::String, user::String, cores::Integer = 2, jobs::Integer = 2)
        new(server, user, cores, jobs)
    end
end


sshcommand(hpc::HPC, command::String) =
    run(`ssh $(hpc.user)"@"$(hpc.server) "source /etc/profile;" $command`)

function createworkspaceinserver(exp::Experiment, hpc::HPC)
    name = exp.name
    @info "Creating a copy of the project in $name direcotry of your folder in server ..."
    workspace = exp.workspace
    sshcommand(hpc, "mkdir -p $workspace")
    run(`scp -r src $(hpc.user)"@"$(hpc.server)":~/"$workspace`)
    run(`scp -r $workspace"/." $(hpc.user)"@"$(hpc.server)":~/"$workspace`)
    # sshCommand("mkdir results/$name")
end


function createtasktemplate(exp::Experiment, hpc::HPC)
    home_directory = @capture_out run(`ssh "amraj@login2.hpc.dtu.dk" 'pwd'`)
    home_directory = home_directory[1:end-1] # To remove '\n'
    workspace = exp.workspace
    tpl = template()
    data = Dict(
        "name" => exp.name,
        "workspace" => "$home_directory/$workspace",
        "cores" => hpc.cores,
        "cluster" => "compute",
        "command" =>
            "julia $home_directory/$workspace/main.jl --project=$home_directory/$workspace",
    )
    rendered = render(tpl, data)
    open("$workspace/job.sh", "w") do io
        write(io, rendered)
    end
end

function submitjob(exp::Experiment, hpc::HPC)
    tasknumber = hpc.jobs
    workspace = exp.workspace
    bash_file = "job.sh"
    thejob = "cd $workspace && for i in {1..$tasknumber};  do bsub < $bash_file -env SERVER_ID=\$i ; sleep 0.2; done"
    @info sshcommand(hpc, thejob)
end


function fetchresults(exp::Experiment, hpc::HPC)
    workspace = exp.workspace
    hpcresult = workspace * "/hpc-" * hpc.server
    if !ispath(hpcresult)
        mkdir(hpcresult)
    end

    run(`scp -r $workspace"/." $(hpc.user)"@"$(hpc.server)":~/"$workspace"/*" $hpcresult`)
    @info "The results folder is downloaded in $hpcresult."
end

function fetch(exp::Experiment, hpc::HPC)
    s = sshcommand(hpc, "bstat")
    if success(s)
        @capture_out s
    end
    fetchresults(exp, hpc)
end

function showerror(exp::Experiment, hpc::HPC)
    workspace = exp.workspace
    command = "cat amraj@login2.hpc.dtu.dk:~/$workspace/Error.err"
    s = sshcommand(hpc, command)
    if success(s)
        @capture_out s
    end
end




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

# function submitTask(workspace, taskfile, tasknumber=40)
#     home_directory = @capture_out run(`ssh "amraj@login2.hpc.dtu.dk" 'pwd'`)
#     home_directory = home_directory[1:end-1] # To remove '\n'
#     command = "$home_directory/julia/$workspace/$taskfile"
#     bash_file = "$home_directory/julia/$workspace/server/templates/$workspace.sh"
#     createTaskTemplate(workspace, command)
#     createWorkSpaceInServer(workspace) #Uncomment to work
#     thejob = "for i in {1..$tasknumber}; do bsub < $bash_file ; sleep 1; done"
#     @info sshCommand(thejob)
#     # @info @capture_out run(`ssh amraj@login2.hpc.dtu.dk $thejob`)
# end

# function removeWorkSpaceInServer(name)
#     sshCommand("rm -rf julia/$name")
# end
#
# function removeWorkSpaceDataServer(name)
#     sshCommand("rm -rf results/$name")
# end
