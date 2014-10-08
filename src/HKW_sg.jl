dir = dirname(@__FILE__())
lib =  joinpath(dir, "libHKW_sg.so")

function scengen_HKW!(tgMoms::Array{Float64, 2}, tgCorrs::Array{Float64, 2},
                     scenarios::Array{Float64, 2}, probs::Array{Float64, 1}, 
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20,
                     formatOfMoms::Int64 = 0)
    dimMoms = size(tgMoms)
    dimCorrs = size(tgCorrs)
    dim = dimCorrs[1]
    numScen = size(scenarios)[1]
    #@assert(dimMoms[2] = 4, "Moments must be input in an n x 4 matrix")
    #@assert(dimCorrs[1] == dimCorrs[2], "Correlation matrix must be square")
    #@assert(dimCorrs[1] == dimMoms[1], "Moment and correlation matrices must have same number of rows")
    ccall( (:srand,), Void, (Uint64, ), 0)
    @eval ccall( (:scengen_HKW_julia, $lib),
                Int64,
                (Ptr{Float64}, Int64, Ptr{Float64}, Ptr{Float64},
                 Int64, Int64, Ptr{Float64},
                 Float64, Float64, Int64, Int64, Int64, Int64,
                 Ptr{Float64}, Ptr{Float64}, Ptr{Int64}, Ptr{Int64}),
                $tgMoms, $formatOfMoms, $tgCorrs, $probs,
                $dim, $numScen, $scenarios, $maxErrMom, $maxErrCor,
                0, $maxTrial, $maxIter, 0,
                C_NULL, C_NULL, C_NULL, C_NULL)
end

function scengen_HKW(tgMoms::Array{Float64, 2}, tgCorrs::Array{Float64, 2}, numScen::Int64,
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20,
                     formatOfMoms::Int64 = 0)
    dim = size(tgCorrs)[1]
    scenarios = Array(Float64, numScen, dim)
    probs = [1.0/numScen for i=1:numScen]
    scengen_HKW!(tgMoms, tgCorrs, scenarios, probs, maxErrMom, maxErrCor,
                maxTrial, maxIter, formatOfMoms)
    return scenarios
end
