using Pidoh
using Random

n = 50
problem = OneMax(n)

@testset "Simulated Annealing Correctness" begin
    algorithm = sa(FixedCooling(50.0), stop=FixedBudget(10^10))
    instance = Instance(generator=RandBitStringIP(n), problem)
    experiment = Experiment("_tests_sac", [algorithm], [instance], directory=false)
    res = run(experiment)
    optx = res.jobs[1].trace.optimum
    @test sum(optx.individual) == optimum(problem)
end
