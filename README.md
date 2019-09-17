# MomentMatching.jl

This package provides functionality for generating scenario sets whose marginals have specified first four moments and given correlation structure. It is a Julia interface for the C API developed by [Michal Kaut](http://work.michalkaut.net/) which implements the moment matching algorithm described in the following paper:

- Høyland, K., Kaut, M. & Wallace, S.W. Computational Optimization and Applications (2003) 24: 169. https://doi.org/10.1023/A:1021853807313

# Installation

In the package mode in the Julia REPL, run the following command:

```julia
pkg> add https://github.com/fairbrot/MomentMatching.jl.git
```

The package build process compiles C source code and assumes the user has `make` and `gcc` installed on their computer.
This package software was developed on Linux, and so it is possible that this build process may need to be adapted for other operating systems.

# Basic Usage

The package provides two main functions:

- `moments`: utility for calculating the first four moments of each marginal of a scenario set
- `scengen_HKW`: function for generating scenario set with required moments and correlations

Moments are specified by a d x 4 matrix where d is the number of dimensions of the required scenario set.
The specified moments are mean, standard deviation, skewness and kurtosis.
Correlations are specified by a d x d matrix.

## Example

```julia
tg_moms = [[0.0 1.0 1.0 0.0]; [1.0 2.0 -1.0 1.0]] # Target moments
tg_cors = [[1 0.5]; [0.5 1]] # Target correlations
num_scen = 100
scenarios = scengen_HKW(tg_moms, tg_cors, num_scen)
```

The `moments` function can be used to query the moments of the generated scenario set:

```julia
moms = moments(scenarios)
```

## Other options
By default, the `scengen_HKW` assumes that the constructed scenarios are equiprobable. However, a method of the function exists which allows users to specify a vector of probabilities for the scenarios which are output by the algorithm.
The function also has several keyword arguments which allow the user to control algorithm behaviour such as required accuracy of the scenario set's moments and correlations.
A method of `moments` also exists which allows the user to specify probabilities of scenarios.
Refer to the package documentation for more detailed information on the options available for these functions.

```julia
help?> scengen_HKW
```
