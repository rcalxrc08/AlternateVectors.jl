<!-- =============================
     ABOUT
    ============================== -->
\begin{section}{title="About this Package", name="About"}
\lead{AlternateVectors.jl is a Julia package containing some useful array representation for peculiar one dimensional arrays patterns.}
It currently contains the following types:

- AlternateVector: convenient representation for vectors of the form:
	`````
	[a,b,a,b,a,b...]
	`````
	
- AlternatePaddedVector: convenient representation for vectors of the form:
    `````
    [x,a,b,a,b,a,b...,y]
    `````
The module is standalone.
\end{section}
\begin{section}{title="Getting Started", name="Usage"}
**_AlternateVector_**

To build a AlternateVector one needs to provide:
* the value for odd indices
* the value for even indices
* the length.
The various values must be of the same type and the length must be greater than one.
The way to build an AlternateVector is the following:
```julia:example_build_alternate_vector
using AlternateVectors
value_odd=0.2
value_even=2.3
length_av=7
x_av=AlternateVector(value_odd,value_even,length_av)
```
**_AlternatePaddedVector_**

To build a AlternatePaddedVector one needs to provide: 
* the initial value
* the value for even indices
* the value for odd indices
* the final value
* the length
The various values must be of the same type and the length must be greater than three.
The way to build an AlternatePaddedVector is the following:
```julia:example_build_alternate_padded_vector
using AlternateVectors
initial_value=0.2
value_odd=-0.2
value_even=2.3
final_value=1.3
length_av=7
x_av=AlternatePaddedVector(initial_value,value_even,value_odd,final_value,length_av)
```

**_Operation on Alternate Vectors_**

The following applies:
* AlternateVector/AlternatePaddedVector is closed under getindex for range of integers.
```julia:example_unary_operations_1
using AlternateVectors
apv=AlternatePaddedVector(0.2,-2.0,4.0,2.3,70)
z_small=apv[1:7:50]
z_small
```
* Any scalar unary function applied directly to AlternateVectors/AlternatePaddedVector will produce an array of the same type.
```julia:example_unary_operations_2
using AlternateVectors
av=AlternateVector(0.2,-2.0,10)
z_sin=@. sin(av)
z_sin
```
**_Operation between Alternate Vectors_**

The following applies:
* Binary scalar functions between AlternateVector and AlternateVector will produce AlternateVector.
* Binary scalar functions between AlternatePaddedVector and AlternatePaddedVector will produce AlternatePaddedVector.
* Binary scalar functions between AlternatePaddedVector and AlternateVector will produce AlternatePaddedVector.
* Binary scalar functions between AlternatePaddedVector/AlternateVector and **any** other type deriving from AbstractArray will produce an array of the other type.

```julia:example_binary_operations
using AlternateVectors
x=AlternateVector(0.2,2.3,10)
y=randn(10)
z=AlternatePaddedVector(0.2,-2.0,4.0,2.3,10)
@. sin(x)*y+z
```
\end{section}
\begin{section}{title="Performances Comparison", name="Performances"}
Here the common usages of the package are tested.

**_Simple multiplication_**
```julia:performance_test_multiplication
using AlternateVectors, BenchmarkTools
n=10_000
x=AlternateVector(0.2,2.3,n)
y=randn(n)
x_c=collect(x)
@btime @. $x*$y;
@btime @. $x_c*$y;
```

**_Flipping sign based on index and sum_**
```julia:performance_test_alternate_vector
using AlternateVectors, BenchmarkTools, LinearAlgebra
n=10_000
function f_std_scalar(f_x)
	N=length(f_x)
	sum_z=zero(eltype(f_x))
	for i in 1:N
		w=ifelse(isodd(i),1,-1)
		sum_z+=@views @inbounds w*f_x[i]
	end
	return sum_z
end

function f_std_scalar_2(f_x)
	N=length(f_x)
	sum_z=zero(eltype(f_x))
	for i in 1:N
		if(isodd(i))
			sum_z+=@views @inbounds f_x[i]
		else
			sum_z-=@views @inbounds f_x[i]
		end
	end
	return sum_z
end

function f_std_vec(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(isodd(idx),1,-1)
	return sum(W.*f_x)
end

function f_std_vec_linear_algebra(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(isodd(idx),1,-1)
	return dot(W,f_x)
end

function f_apv(f_x)
	N=length(f_x)
	W=AlternateVector(1,-1,N)
	return sum(W.*f_x)
end
x=randn(n)
f_x=@. sin(x)+x*cos(x)
@btime f_std_scalar($f_x);
@btime f_std_scalar_2($f_x);
@btime f_std_vec($f_x);
@btime f_std_vec_linear_algebra($f_x);
@btime f_apv($f_x);
```
**_Simpson Integration_**
```julia:performance_test_alternate_padded_vector
using AlternateVectors, BenchmarkTools,LinearAlgebra
n2=10_000
function f_simpson_std_scalar(f_x)
	N=length(f_x)
	sum_z=zero(eltype(f_x))
	for i in 1:N
		w=ifelse(i==1,1/3,ifelse(i==N,1/3,4/3))
		sum_z+=@views @inbounds w*f_x[i]
	end
	return sum_z
end

function f_simpson_std_vec(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(idx==1,1/3,ifelse(idx==N,1/3,4/3))
	return sum(W.*f_x)
end

function f_simpson_std_vec_linear_algebra(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(idx==1,1/3,ifelse(idx==N,1/3,4/3))
	return dot(W,f_x)
end

function f_simpson_apv(f_x)
	N=length(f_x)
	W=AlternatePaddedVector(1/3,4/3,4/3,1/3,N)
	return sum(W.*f_x)
end

function f_simpson_apv_linear_algebra(f_x)
	N=length(f_x)
	W=AlternatePaddedVector(1/3,4/3,4/3,1/3,N)
	return dot(W,f_x)
end

x2=randn(n2)
f_x2=@. sin(x2)+x2*cos(x2)
@btime f_simpson_std_scalar($f_x2);
@btime f_simpson_std_vec($f_x2);
@btime f_simpson_std_vec_linear_algebra($f_x2);
@btime f_simpson_apv($f_x2);
@btime f_simpson_apv_linear_algebra($f_x2);
```
To be noticed the performance improvements thanks to the usage of AlternatePaddedVector, and to be noticed that the first function proposed is not compatible with the CUDA.jl stack.

\end{section}