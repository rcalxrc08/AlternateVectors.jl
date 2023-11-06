# AlternateVectors

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://rcalxrc08.github.io/AlternateVectors.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://rcalxrc08.github.io/AlternateVectors.jl/dev/)
[![Build Status](https://github.com/rcalxrc08/AlternateVectors.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/rcalxrc08/AlternateVectors.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/rcalxrc08/AlternateVectors.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/rcalxrc08/AlternateVectors.jl)

##### This is a Julia package containing some useful Array representation for specific arrays patterns.
It currently contains the following types:

- AlternateVector: convenient representation for arrays of the form:
    ```Julia
    [a,b,a,b,a,b...]
    ```
- AlternatePaddedVector: convenient representation for arrays of the form:
    ```Julia
    [x,a,b,a,b,a,b...,y]
    ```

The module is standalone.

## How to Install
To install the package simply type on the Julia REPL the following:
```Julia
Pkg.clone("https://github.com/rcalxrc08/AlternateVectors.jl")
```
## How to Test
After the installation, to test the package type on the Julia REPL the following:
```julia
Pkg.test("AlternateVectors")
```
## Example of Usage
```julia
#Import the Package
using AlternateVectors
x=AlternateVectors(0.2,2.3,10)
@show @. sin(x)
```
