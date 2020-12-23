module MomentMatching

using StatsBase

export scengen_HKW, moments

const LIB_HKW =  normpath(@__DIR__, "../deps/HoylandKautWallace", "libHKW_sg.so")
include("HKW_sg.jl")

end
