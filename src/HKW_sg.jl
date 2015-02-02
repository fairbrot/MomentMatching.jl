# using Distributions

dir = dirname(@__FILE__())
const lib =  joinpath(dir, "libHKW_sg.so")

function cor_to_cov(cor::Matrix{Float64}, var::Vector{Float64})
    dim = size(cor,1)
    Σ = Array(Float64, dim, dim)
    for i in 1:dim
        for j in 1:dim
            Σ[i,j] = cor[i,j]*sqrt(var[i]*var[j])
        end
    end
    Σ
end

function scengen_HKW!(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64},
                     scenarios::Matrix{Float64}, probs::Array{Float64, 1}, 
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20,
                     formatOfMoms::Int64 = 2)
    dimMoms = size(tgMoms)
    dimCorrs = size(tgCorrs)
    dim = dimCorrs[1]
    numScen = size(scenarios)[1]
    #@assert(dimMoms[2] = 4, "Moments must be input in an n x 4 matrix")
    #@assert(dimCorrs[1] == dimCorrs[2], "Correlation matrix must be square")
    #@assert(dimCorrs[1] == dimMoms[1], "Moment and correlation matrices must have same number of rows")
    ccall( (:scengen_HKW_julia, lib),
                Int64,
                (Ptr{Float64}, Int64, Ptr{Float64}, Ptr{Float64},
                 Int64, Int64, Ptr{Float64},
                 Float64, Float64, Int64, Int64, Int64, Int64,
                 Ptr{Float64}, Ptr{Float64}, Ptr{Int64}, Ptr{Int64}),
                tgMoms, formatOfMoms, tgCorrs, probs,
                dim, numScen, scenarios, maxErrMom, maxErrCor,
                0, maxTrial, maxIter, 0,
                C_NULL, C_NULL, C_NULL, C_NULL)
end

function scengen_HKW(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64}, numScen::Int64,
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20,
                     formatOfMoms::Int64 = 0)
    dim = size(tgCorrs)[1]
    μ = tgMoms[:,1]
    Σ = cor_to_cov(tgCorrs, tgMoms[:,2])
    scenarios = Array(Float64, numScen, dim)
    # scenarios = rand(MvNormal(μ, Σ), numScen)
    probs = fill(1.0/numScen, numScen)
    scengen_HKW!(tgMoms, tgCorrs, scenarios, probs, maxErrMom, maxErrCor,
                maxTrial, maxIter, formatOfMoms)
    return transpose(scenarios)
end
