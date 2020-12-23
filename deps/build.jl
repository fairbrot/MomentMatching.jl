cd(joinpath(@__DIR__, "HoylandKautWallace"))

if Sys.isunix()
    run(`make`)
elseif Sys.iswindows()
    run(`mingw32-make`) # See guide for Windows at https://www.codementor.io/@evalparse/making-compiling-c-functions-for-use-in-julia-on-windows-f9lwa5i43
end
