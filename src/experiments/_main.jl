
println("HELLO from ", ENV["SERVER_ID"])

server_id = parse(Integer, ENV["SERVER_ID"])

using Logging

logger = SimpleLogger(stdout, Logging.Debug)
global_logger(logger)

using Pkg
Pkg.status()
Pkg.activate(".")
Pkg.instantiate()

using Pidoh
using LightGraphs, SimpleWeightedGraphs
using SparseArrays


experiment = loadexperiment("./data.jld2")
run(experiment, server_id)
