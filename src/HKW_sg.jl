dir = dirname(@__FILE__())
const lib =  joinpath(dir, "libHKW_sg.so")

"""
    moments(scenarios::Matrix{Float64}, [probs::Vector{Float64}])
    
Calculates the first four moments (mean, std, skewness, kurtosis) 
of multivariate observations and returns as an n x 4 matrix
where the i-th row gives the moments for the i-th dimension
of the input matrix.

# Arguments
- `scenarios::Matrix{Float64}`: input observations where each column
                                corresponds to a single observation.
- `probs::Vector{Float64}`: vector containing weights of each observation
"""
function moments end

function moments(scenarios::Matrix{Float64})
    dim = size(scenarios,1)
    moms = Array{Float64}(undef, dim, 4)
    for i in 1:dim
        marg_scens = vec(scenarios[i,:])
        moms[i,1], moms[i,2] = mean_and_std(marg_scens, corrected=false)
        moms[i,3] = skewness(marg_scens, moms[i,1])
        moms[i,4] = kurtosis(marg_scens, moms[i,1])
    end
    return moms
end

function moments(scenarios::AbstractMatrix, probs::Vector{Float64})
    dim, nscen = size(scenarios)
    length(probs) == nscen || throw(DimensionMismatch("Inconsistent array lengths."))
    moms = Array{Float64}(undef, dim, 4)
    wv = Weights(probs)
    for i in 1:dim
        marg_scens = vec(scenarios[i,:])
        moms[i,1], moms[i,2] = mean_and_std(marg_scens, wv, corrected=false)
        moms[i,3] = skewness(marg_scens, wv, moms[i,1])
        moms[i,4] = kurtosis(marg_scens, wv, moms[i,1])
    end
    return moms
end


function scengen_HKW!(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64},
                      outScen::Matrix{Float64}, probs::Array{Float64, 1};
                      maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                      maxTrial::Int64 = 10, maxIter::Int64 = 20, outputLevel::Int64=0)
    
    dim = size(tgCorrs,1)
    numScen = size(outScen)[2]
    formatOfMoms::Int64 = 4
    @assert(size(tgMoms, 2) == 4, "Moments must be input in an n x 4 matrix")
    @assert(size(tgCorrs, 1) == size(tgCorrs, 2), "Correlation matrix must be square")
    @assert(size(tgCorrs, 1) == size(tgMoms, 1), "Moment and correlation matrices must have same number of rows")
    errMom = Array{Float64}(undef, 1)
    errCorr = Array{Float64}(undef, 1)
    TestLevel=2
    ccall( (:scengen_HKW_julia, lib),
                Int64,
                (Ptr{Float64}, Int64, Ptr{Float64}, Ptr{Float64},
                 Int64, Int64, Ptr{Float64},
                 Float64, Float64, Int64, Int64, Int64, Int64,
                 Ptr{Float64}, Ptr{Float64}, Ptr{Int64}, Ptr{Int64}),
                copy(tgMoms), formatOfMoms, tgCorrs, probs,
                dim, numScen, outScen, maxErrMom, maxErrCor,
                outputLevel, maxTrial, maxIter, 0,
                errMom, errCorr, C_NULL, C_NULL)
    if errMom[1] > maxErrMom
        warn("Error in moments is greater than maximum specified error")
    end
    if errCorr[1] > maxErrCor
        warn("Error in correlations is greater than maximum specified error")
    end
end


"""
    scengen_HKW(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64}, probs::Vector{Float64}; kwargs...)
    scengen_HKW(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64}, num_scen::Int; kwargs...)

Generate a scenario set whose marginals have specified first four moments
and which has a specified correlation matrix.

# Arguments
- `tgMoms::Matrix{Float64}`: target moments matrix where each row gives the first four moments of a marginal
- `tgCorrs:Matrix{Float64}`: target correlation matrix
- `probs::Vector{Float64}`: probabilities of generated scenarios
- `numScen::Int`: if specified instead of `probs`, generates equiprobable `numScen` scenarios

# Keyword Arguments
- `maxErrMom::Float64`: maximum allowed error in target moments
- `maxErrCor::Float64`: maximum allowed error in target correlations
- `maxTrial::Int`: maximum number of times algorithm is restarted with new initial scenarios
- `maxIter::Int`: maximum number of iterations in one trial
- `outputLevel::Int`: level of algorithm run information to be printed to standard output

# References

Høyland, K., Kaut, M. & Wallace, S.W. Computational Optimization and Applications (2003) 24: 169. https://doi.org/10.1023/A:1021853807313
"""
function scengen_HKW end

function scengen_HKW(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64},
                     probs::Vector{Float64}; kwargs...)
    formatOfMoms = 4 # Mean, Std. Dev, Skewness, Excess kurtosis
    dim = size(tgCorrs,1)
    numScen = length(probs)
    scenarios = Array{Float64}(undef, dim, numScen)
    scengen_HKW!(tgMoms, tgCorrs, scenarios, probs; kwargs...)
    return scenarios
end

function scengen_HKW(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64},
                     numScen::Int64; kwargs...)
    probs = fill(1.0/numScen, numScen)
    return scengen_HKW(tgMoms, tgCorrs, probs; kwargs...)
end
