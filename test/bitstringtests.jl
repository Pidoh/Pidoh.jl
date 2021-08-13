using Pidoh
using Random

@testset "Flip bit string" begin
    @test flip(true) == false
    @test flip(false) == true
end

@testset "OneMax Fitness Function" begin
    @test fitness(BitArray([true, true, true]), OneMax(3)) == 3
    @test fitness(BitArray([false, false, false, false]), OneMax(4)) == 0
    @test fitness(BitArray([]), OneMax(0)) == 0
end


@testset "ZeroMax Fitness Function" begin
    @test fitness(BitArray([true, true, true]), ZeroMax(3)) == 0
    @test fitness(BitArray([false, false, false, false]), ZeroMax(4)) == 4
    @test fitness(BitArray([]), ZeroMax(0)) == 0
end


jump = Jump(10, 3)
@testset "ZeroMax Fitness Function" begin
    @test fitness(BitArray([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), jump) == jump.jumpsize
    @test fitness(BitArray([1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), jump) == jump.jumpsize + 1
    @test fitness(BitArray([1, 1, 1, 1, 1, 1, 1, 1, 1, 1]), jump) == jump.jumpsize + 10
    @test fitness(BitArray([1, 1, 1, 1, 1, 1, 1, 1, 1, 0]), jump) == 1
    @test fitness(BitArray([1, 1, 1, 1, 1, 1, 1, 0, 0, 0]), jump) == 10
    @test fitness(BitArray([1, 1, 1, 1, 1, 1, 1, 1, 0, 0]), jump) == 2

end


ins1 = Instance(BitArray([true, true, false]), OneMax(3))

@testset "UniformlyIndependentMutation mutation" begin
    @test mutation(ins1, UniformlyIndependentMutation(0.0)).individual == ins1.individual
    @test mutation(ins1, UniformlyIndependentMutation(1.0)).individual != ins1.individual
    @test fitness(mutation(ins1, UniformlyIndependentMutation(1.0))) == 1
end
