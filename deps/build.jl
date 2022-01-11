cd(joinpath(@__DIR__, "HoylandKautWallace"))

if Sys.isunix()
    run(`make`)
elseif Sys.iswindows()
    # See guide for Windows at https://www.codementor.io/@evalparse/making-compiling-c-functions-for-use-in-julia-on-windows-f9lwa5i43
    # Download MinGW-w64: https://www.mingw-w64.org/downloads/#mingw-builds and add bin to path
    run(`mingw32-make`)
end
