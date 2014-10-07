function scengen_HKW(tgMoms::Array{Float64, 2}, tgCorrs::Array{Float64, 2}, numScen::Int64,
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20,
                     formatOfMoms::Int64 = 0)
    dimMoms = size(tgMoms)
    dimCorrs = size(tgCorrs)
    #@assert(dimMoms[2] = 4, "Moments must be input in an n x 4 matrix")
    #@assert(dimCorrs[1] == dimCorrs[2], "Correlation matrix must be square")
    #@assert(dimCorrs[1] == dimMoms[1], "Moment and correlation matrices must have same number of rows")
    scenarios = Array(Float64, numScen, dimCorrs[1])
    ccall( (:srand,), Void, (Uint64, ), 3)
    ccall( (:scengen_HKW_julia, "./libHKW_sg.so"),
          Int64,
          (Ptr{Float64}, Int64, Ptr{Float64}, Ptr{Float64},
           Int64, Int64, Ptr{Float64},
           Float64, Float64, Int64, Int64, Int64, Int64,
           Ptr{Float64}, Ptr{Float64}, Ptr{Int64}, Ptr{Int64}),
          tgMoms, formatOfMoms, tgCorrs, C_NULL,
          dimCorrs[1], numScen, scenarios, maxErrMom, maxErrCor,
          2, maxTrial, maxIter, 0,
          C_NULL, C_NULL, C_NULL, C_NULL)
    return scenarios
end

tg_moms = [[0.0 1.0 0.5 1.5], [1.0 2.0 -0.5 5.0]]
tg_cors = [[1 0.5], [0.5 1]]
num_scen = 100
scenarios = scengen_HKW(tg_moms, tg_cors, num_scen)
