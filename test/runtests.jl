using Pidoh
using Test
using SafeTestsets


@safetestset "BitString Tests" begin include("bitstringtests.jl") end
@safetestset "Instance Tests" begin include("instancetests.jl") end


@testset "Pidoh.jl" begin
    # Write your tests here.
end
