using MomentMatching
using LinearAlgebra
using Statistics
using Test

@testset "Simple testset from HKW" begin
    tg_moms = [[0.0 1.0 1.0 0.0]; [1.0 2.0 -1.0 1.0]]
    tg_cors = [[1 0.5]; [0.5 1]]
    num_scen = 1000
    scenarios = scengen_HKW(tg_moms, tg_cors, num_scen)
    probs = fill(1.0/num_scen, num_scen)

    moms = moments(scenarios, probs)
    cors = cor(scenarios, dims=2)

    @test norm(moms - tg_moms, Inf) < 1e-3
    @test norm(cors - tg_cors, Inf) < 1e-3
end
