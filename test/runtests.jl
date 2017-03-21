using MomentMatching
using Base.Test

tg_moms = [[0.0 1.0 1.0 0.0]; [1.0 2.0 -1.0 1.0]]
tg_cors = [[1 0.5]; [0.5 1]]
num_scen = 1000
scenarios = scengen_HKW(tg_moms, tg_cors, num_scen)
probs = fill(1.0/num_scen, num_scen)

moms = moments(scenarios, probs)
cors = Base.corm(scenarios, mean(scenarios, 2), 2)

@test norm(moms - tg_moms) < 1e-3
@test norm(cors - tg_cors) < 1e-3
