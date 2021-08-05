using Pidoh
using Random

@testset "Fixed Cooling" begin
    constant = 0.1234
    fc = FixedCooling(constant)
    @test temperature(fc, 1) == constant
    @test temperature(fc, 1000) == constant
end

@testset "Interval Cooling" begin
    temp = 100
    ic = IntervalCooling(1000, 2)
    for i = 1:1000
        temp = temperature(ic, temp)
    end
    @test abs(temp - 50) < 0.0001
end
