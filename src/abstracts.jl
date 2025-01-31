#Implementation for the abstract type
abstract type AbstractAlternateVector{T} <: AbstractArray{T, 1} end
# IO
Base.showarg(io::IO, A::AbstractAlternateVector, _) = print(io, typeof(A))
### Implementation of the array interface
Base.size(A::AbstractAlternateVector) = (A.n,)
Base.getindex(x::AbstractAlternateVector, ::Colon) = x
# Broacasting relation against other arrays
abstract type AbstractArrayStyleAlternateVector <: Broadcast.AbstractArrayStyle{1} end
Base.BroadcastStyle(::AbstractArrayStyleAlternateVector, ::Base.Broadcast.Style{Tuple}) = Broadcast.DefaultArrayStyle{1}()
function Base.BroadcastStyle(a::AbstractArrayStyleAlternateVector, b::Broadcast.DefaultArrayStyle{N}) where {N}
    if (N > 0)
        return AlternateMixtureArrayStyle(b)
    end
    return a
end

function Base.BroadcastStyle(a::AbstractArrayStyleAlternateVector, b::Broadcast.AbstractArrayStyle{N}) where {N}
    if (N > 0)
        return AlternateMixtureArrayStyle(b)
    end
    return Base.BroadcastStyle(a, Broadcast.DefaultArrayStyle{0}())
end
function materialize_if_needed(bc::Base.Broadcast.Broadcasted{T, Nothing, <:F, <:R}) where {T <: AbstractArrayStyleAlternateVector, F, R}
    return Base.materialize(bc)
end

#Optimization for broadcasting
struct AlternateMixtureArrayStyle{T <: Base.Broadcast.BroadcastStyle} <: Base.Broadcast.BroadcastStyle
    sub_style::T
    function AlternateMixtureArrayStyle(mode::V) where {V <: Base.Broadcast.BroadcastStyle}
        return new{V}(mode)
    end
    function AlternateMixtureArrayStyle(style_1::V, style_2::U) where {V <: Base.Broadcast.BroadcastStyle, U <: Base.Broadcast.BroadcastStyle}
        style_implied_1 = Base.BroadcastStyle(style_1, style_2)
        style_implied_2 = Base.BroadcastStyle(style_2, style_1)
        style = ifelse(style_implied_1 == Base.Broadcast.Unknown(), style_implied_2, style_implied_1)
        return AlternateMixtureArrayStyle(style)
    end
end

get_style(x::AlternateMixtureArrayStyle) = x.sub_style

function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, b::Broadcast.AbstractArrayStyle{N}) where {N}
    return AlternateMixtureArrayStyle(get_style(a), b)
end

function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, b::Broadcast.DefaultArrayStyle{N}) where {N}
    return AlternateMixtureArrayStyle(get_style(a), b)
end
function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, ::AbstractArrayStyleAlternateVector)
    return a
end
function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, b::AlternateMixtureArrayStyle)
    return AlternateMixtureArrayStyle(get_style(a), get_style(b))
end

function materialize_if_needed(bc::Base.Broadcast.Broadcasted{AlternateMixtureArrayStyle{T}, Nothing, <:F, <:R}) where {T, F, R}
    return Base.materialize(bc)
end

function materialize_if_needed(bc)
    return bc
end

function Base.materialize(bc::Base.Broadcast.Broadcasted{AlternateMixtureArrayStyle{T}, Nothing, <:F, <:R}) where {T, F, R}
    mat_args = materialize_if_needed.(bc.args)
    res = Base.materialize(Base.Broadcast.Broadcasted(get_style(bc.style), bc.f, mat_args))
    return res
end
