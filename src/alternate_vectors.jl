#Implementation of the concrete class AlternateVector
mutable struct AlternateVector{T} <: AbstractAlternateVector{T}
    value_odd::T
    value_even::T
    const n::Int64
    function AlternateVector(value_odd::T, value_even::T, n::Int64) where {T}
        (2 <= n) || throw("length of AlternateVector must be greater than one. Provided is $n.")
        return new{T}(value_odd, value_even, n)
    end
end

function Base.getindex(x::AlternateVector, ind::Int)
    @boundscheck (1 <= ind <= x.n) || throw(BoundsError(x, ind))
    ifelse(isodd(ind), x.value_odd, x.value_even)
end

# AlternateVector is closed under getindex.
function Base.getindex(A::AlternateVector, el::AbstractRange{T}) where {T <: Int}
    first_idx = el.start
    new_len = length(el)
    (2 <= new_len) || throw("Trying to getindex with an AbstractRange of length $n. Provided length must be greater than one.")
    @boundscheck (1 <= first_idx <= A.n) || throw(BoundsError(A, first_idx))
    @boundscheck (1 <= el.stop <= A.n) || throw(BoundsError(A, el.stop))
    @views @inbounds odd_value = A[first_idx]
    @views @inbounds even_value = A[first_idx+step(el)]
    return AlternateVector(odd_value, even_value, new_len)
end

struct ArrayStyleAlternateVector <: AbstractArrayStyleAlternateVector end
Base.BroadcastStyle(::Type{<:AlternateVector{T}}) where {T} = ArrayStyleAlternateVector()

#Broacasting over AlternateVector
flatten_even(x) = x
flatten_even(x::AbstractArray{T, 0}) where {T} = x[]
flatten_even(x::Base.RefValue) = x.x
flatten_odd(x) = flatten_even(x)
flatten_even(x::AlternateVector) = x.value_even
flatten_odd(x::AlternateVector) = x.value_odd

function Base.materialize(bc::Base.Broadcast.Broadcasted{ArrayStyleAlternateVector, Nothing, <:F, <:R}) where {F, R}
    bc_f = Broadcast.flatten(bc)
    func = bc_f.f
    args = bc_f.args
    axes_result = Broadcast.combine_axes(args...)
    odd_part = func(flatten_odd.(args)...)
    even_part = func(flatten_even.(args)...)
    return AlternateVector(odd_part, even_part, length(first(axes_result)))
end


function internal_fill!(dest::AlternateVector{T},el_odd::T,el_even::T) where {T}
	dest.value_odd = el_odd
    dest.value_even = el_even
    return dest
end

function Base.materialize!(dest::AlternateVector, bc::Base.Broadcast.Broadcasted{AlternateVectors.ArrayStyleAlternateVector, Nothing, <:F, <:R}) where {F, R}
    bc_f = Broadcast.flatten(bc)
    func = bc_f.f
    args = bc_f.args
    axes_result = Broadcast.combine_axes(args...)
	internal_fill!(dest,func(AlternateVectors.flatten_odd.(args)...),func(AlternateVectors.flatten_even.(args)...))
    return dest
end

Base.similar(a::AlternateVector, ::Type{T}, dims::Dims{1}) where {T}    = AlternateVector(zero(T),zero(T), dims[1])


function Base.fill!(x::AlternateVector{T},el) where {T}
	el_T=T(el)
	internal_fill!(x,el_T,el_T)
	return x
end

function Base.sum(x::AlternateVector)
    isfinalodd = isodd(x.n)
    nhalf = div(x.n, 2)
    return muladd(nhalf, x.value_even, (nhalf + isfinalodd) * x.value_odd)
end

using ChainRulesCore
function ChainRulesCore.rrule(::Type{AlternateVector}, value_odd::T, value_even::T, n::Int64) where {T}
    function AlternateVector_pb(Δapv)
        odd_v = AlternateVector(one(T), zero(T), n)
        odd_der = sum(odd_v .* Δapv)
        even_der = sum(Δapv) - odd_der
        NoTangent(), odd_der, even_der, NoTangent()
    end
    return AlternateVector(value_odd, value_even, n), AlternateVector_pb
end
