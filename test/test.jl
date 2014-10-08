using MomentMatching: scengen_HKW
using Base.Test

function moments(x::Array{Float64, 2}, probs::Array{Float64, 1})
    dim = size(x,2)
    m = Array(Float64, dim)
    for i=1:dim m[i] = dot(scenarios[:,i], probs) end
    m2 = Array(Float64, dim)
    for i=1:dim m2[i] = dot(scenarios[:,i].^2, probs) end
    m3 = Array(Float64, dim)
    for i=1:dim m3[i] = dot(scenarios[:,i].^3, probs) end
    m4 = Array(Float64, dim)
    for i=1:dim m4[i] = dot(scenarios[:,i].^4, probs) end

    v = m2 - m.^2
    sd = sqrt(v)
    mom_matrix = Array(Float64, dim, 4)
    mom_matrix[:,1] = m
    mom_matrix[:,2] = sd
    mom_matrix[:,3] = (m3 - 3*m.*v - m.^3)./(sd.^3)
    mom_matrix[:,4] = (m4 - 4*m3.*m + 6*m2.* (m.^2) - 3*m.^3)./(sd.^4)
    return mom_matrix
end
                
function moments(x::Array{Float64, 2})
    dim = size(x,2)
    m = mean(x,1)
    m2 = mean(x.^2, 1)
    m3 = mean(x.^3, 1)
    m4 = mean(x.^4, 1)
    
    v = m2 - m.^2
    sd = sqrt(v)
    mom_matrix = Array(Float64, dim, 4)
    mom_matrix[:,1] = m                                                    # Mean
    mom_matrix[:,2] = sd                                                   # Standard deviation
    mom_matrix[:,3] = (m3 - 3*m.*v - m.^3)./(sd.^3)                        # Skew
    mom_matrix[:,4] = (m4 - 4*m3.*m + 6*m2.* (m.^2) - 3*m.^3)./(sd.^4)      # Kurtosis
    return mom_matrix
end
                

tg_moms = [[0.0 1.0 0.5 1.5], [1.0 2.0 -0.5 5.0]]
tg_cors = [[1 0.5], [0.5 1]]
num_scen = 100
scenarios = scengen_HKW(tg_moms, tg_cors, num_scen)

@test norm(moments(scenarios) - tg_moms) < 1e-3
@test norm(cor(scenarios) - tg_cors) < 1e-3
