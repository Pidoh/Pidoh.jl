using Pidoh
using Random

@testset "Flip bit string" begin
    @test flip(true) == false
    @test flip(false) == true
end

onemax = OneMax()

@testset "OneMax Fitness Function" begin
    @test fitness(BitArray([true,true,true]), onemax) == 0
    @test fitness(BitArray([false,false,false, false]), onemax) == 4
    @test fitness(BitArray([]), onemax) == 0
end


zeromax = ZeroMax()

@testset "ZeroMax Fitness Function" begin
    @test fitness(BitArray([true,true,true]), zeromax) == 3
    @test fitness(BitArray([false,false,false, false]), zeromax) == 0
    @test fitness(BitArray([]), zeromax) == 0
end


jump = Jump(3)
@testset "ZeroMax Fitness Function" begin
    @test fitness(BitArray([0,0,0,0,0,0,0,0,0,0]), jump) == jump.jumpsize
    @test fitness(BitArray([1,0,0,0,0,0,0,0,0,0]), jump) == jump.jumpsize+1
    @test fitness(BitArray([1,1,1,1,1,1,1,1,1,1]), jump) == jump.jumpsize+10
    @test fitness(BitArray([1,1,1,1,1,1,1,1,1,0]), jump) == 1
    @test fitness(BitArray([1,1,1,1,1,1,1,0,0,0]), jump) == 10
    @test fitness(BitArray([1,1,1,1,1,1,1,1,0,0]), jump) == 2

end


ins1 = Instance(BitArray([true,true,false]), OneMax())

@testset "UniformlyIndependentMutation mutation positions" begin
    @test mutationpositions(ins1,UniformlyIndependentMutation(0.0)) == []
    @test mutationpositions(ins1,UniformlyIndependentMutation(1.0)) == Array(1:length(ins1))
end

@testset "UniformlyIndependentMutation mutation" begin
    @test mutation(ins1,UniformlyIndependentMutation(0.0)).individual == ins1.individual
    @test mutation(ins1,UniformlyIndependentMutation(1.0)).individual != ins1.individual
    @test fitness(mutation(ins1,UniformlyIndependentMutation(1.0))) == 2
end
