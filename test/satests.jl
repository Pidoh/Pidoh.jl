using Pidoh
using Random

@testset "Fixed Cooling" begin
    constant = 0.1234
    fc = FixedCooling(constant)
    @test temperature(fc, 1) == constant
    @test temperature(fc, 1000) == constant
end
