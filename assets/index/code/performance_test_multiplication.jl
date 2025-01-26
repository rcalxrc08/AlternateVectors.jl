# This file was generated, do not modify it. # hide
using AlternateVectors, BenchmarkTools
n=10_000
x=AlternateVector(0.2,2.3,n)
y=randn(n)
x_c=collect(x)
@btime @. $x*$y;
@btime @. $x_c*$y;