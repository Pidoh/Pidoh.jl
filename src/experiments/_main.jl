
println("HELLO")

using Logging

logger = SimpleLogger(stdout, Logging.Debug)
global_logger(logger)

using Pkg
Pkg.status()
Pkg.activate(".")
Pkg.instantiate()

using Pidoh
using JLD
data = load("data.jld")
exp = data["Experiment"]

run(exp)
