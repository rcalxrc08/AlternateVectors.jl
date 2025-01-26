# This file was generated, do not modify it. # hide
using AlternateVectors
x=AlternateVector(0.2,2.3,10)
y=randn(10)
z=AlternatePaddedVector(0.2,-2.0,4.0,2.3,10)
@. sin(x)*y+z