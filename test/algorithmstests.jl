using Pidoh
using Random

n = 20
problem = OneMax(n)

@testset "Simulated Annealing Correctness" begin
    algorithm = SimulatedAnnealing(FixedCooling(50.0), stop = FixedBudget(10^10))
    initial = RandBitStringIndividualIP(n)
    experiment = Experiment("_tests_sac", [algorithm], [problem], [initial], save = false)
    res = run!(experiment)
    optx = res.jobs[1].trace.optimum
    @test fitness(optx.individual) == optimum(problem)
end
