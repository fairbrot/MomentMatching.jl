dir = dirname(@__FILE__())
const lib =  joinpath(dir, "libHKW_sg.so")

# Calculates the covariance matrix given a correlation matrix
# and vector of standard deviations
function cor_to_cov(cor::Matrix{Float64}, std::Vector{Float64})
    dim1, dim2 = size(cor)
    dim1 == dim2 || throw(DimensionMismatch("correlation matrix must be square."))
    length(std) == dim1 || throw(DimensionMismatch("correlation matrix an std. dev. vector have inconsistent dimensions."))
    Σ = Array(Float64, dim1, dim1)
    for i in 1:dim1
        for j in 1:dim1
            Σ[i,j] = cor[i,j]*std[i]*std[j]
        end
    end
    Σ
end

# Calculate the first four moments
# of multivariate observations.
#
# Arguments:
# - scenarios each column is a realisation of a random vector
# Returns:
# - moms (dim x 4) matrix where the columns give the mean, std, skewness
#                and excess kurtosis
function moments(scenarios::Matrix{Float64})
    dim = size(scenarios,1)
    moms = Array(Float64, dim, 4)
    for i in 1:dim
        marg_scens = vec(scenarios[i,:])
        moms[i,1], moms[i,2] = mean_and_std(marg_scens)
        moms[i,3] = skewness(marg_scens, moms[i,1])
        moms[i,4] = kurtosis(marg_scens, moms[i,1])
    end
    return moms
end

# Calculate the first four moments
# of multivariate observations.
#
# Arguments:
# - scenarios: each column is a realisation of a random vector
# - probs: vector of probabilities of scenarios
# Returns:
# - moms (dim x 4) matrix where the columns give the mean, std, skewness
#                and excess kurtosis
function moments(scenarios::Matrix{Float64}, probs::Vector{Float64})
    dim, nscen = size(scenarios)
    length(probs) == nscen || throw(DimensionMismatch("Inconsistent array lengths."))
    moms = Array(Float64, dim, 4)
    wv = WeightVec(probs)
    for i in 1:dim
        marg_scens = vec(scenarios[i,:])
        moms[i,1], moms[i,2] = mean_and_std(marg_scens, wv)
        moms[i,3] = skewness(marg_scens, wv, moms[i,1])
        moms[i,4] = kurtosis(marg_scens, wv, moms[i,1])
    end
    return moms
end


# Warning: this function should not be used directly
#          for the following reasons:
#  - function assumes inputted scenarios array rows
#    representing scenario rather than columns
#  - function may segfault if inconsistent dimensions are used
function scengen_HKW!(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64},
                     scenarios::Matrix{Float64}, probs::Array{Float64, 1}, 
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20,
                     formatOfMoms::Int64 = 4)
    dim = size(tgCorrs,1)
    numScen = size(scenarios)[1]
    #@assert(dimMoms[2] = 4, "Moments must be input in an n x 4 matrix")
    #@assert(dimCorrs[1] == dimCorrs[2], "Correlation matrix must be square")
    #@assert(dimCorrs[1] == dimMoms[1], "Moment and correlation matrices must have same number of rows")
    errMom = Array(Float64,1)
    errCorr = Array(Float64, 1)
    ccall( (:scengen_HKW_julia, lib),
                Int64,
                (Ptr{Float64}, Int64, Ptr{Float64}, Ptr{Float64},
                 Int64, Int64, Ptr{Float64},
                 Float64, Float64, Int64, Int64, Int64, Int64,
                 Ptr{Float64}, Ptr{Float64}, Ptr{Int64}, Ptr{Int64}),
                copy(tgMoms), formatOfMoms, tgCorrs, probs,
                dim, numScen, scenarios, maxErrMom, maxErrCor,
                0, maxTrial, maxIter, 0,
                errMom, errCorr, C_NULL, C_NULL)
    if errMom[1] > maxErrMom
        warn("Error in moments is greater than maximum specified error")
    end
    if errCorr[1] > maxErrCor
        warn("Error in correlations is greater than maximum specified error")
    end
end

# Generates a scenario set which whose marginals have specified first four moments
# and which has a specified correlation matrix.
#
# The specified moments are the mean, standard deviation, skewness and excess kurtosis
#
# Arguments:
# - tgMoms target moments matrix where each row gives the first four moments of a marginal
# - tgCorrs target correlation matrix
# - numScen number of scenarios in constructed scenario set
# - maxErrMom maximum allowed error from target moments
# - maxErrCor maximum allowed error from target correlations
# - maxTrial maximum number of times algorithm is restarted with new initial scenarios
# - maxIter maximum number of iterations in one trial
function scengen_HKW(tgMoms::Matrix{Float64}, tgCorrs::Matrix{Float64}, numScen::Int64,
                     maxErrMom::Float64 = 1e-3, maxErrCor = 1e-3,
                     maxTrial::Int64 = 10, maxIter::Int64 = 20)
    formatOfMoms = 4 # Mean, Std. Dev, Skewness, Excess kurtosis 
    dim = size(tgCorrs,1)
    scenarios = Array(Float64, numScen, dim)
    probs = fill(1.0/numScen, numScen)
    scengen_HKW!(tgMoms, tgCorrs, scenarios, probs, maxErrMom, maxErrCor,
                maxTrial, maxIter, formatOfMoms)
    return transpose(scenarios)
end
