using Pidoh
using Random

n = 10
ind1 = bitrand(n)
ins1 = Instance(ind1, OneMax(10))

ins2 = copy(ins1, fitnessvalue = -1)


@testset "Instance functions" begin
    @test ins1.individual == ind1
    @test ins1.fitnessvalue == fitness(ins1)
    @test fitness(ins1) == fitness(ind1, OneMax(10))
    @test length(ind1) == n
    @test ins2.individual == ins1.individual
    # @test fitness(ins2) == -1
    # typeof(ins1.problem) <: AbstractProblem
end
