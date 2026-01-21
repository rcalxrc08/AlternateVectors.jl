# Implementation for the abstract type

# Abstract type for all AlternateVectors, parameterized by element type T.
abstract type AbstractAlternateVector{T} <: AbstractArray{T, 1} end

# IO

# Customizes how AbstractAlternateVector types are shown in argument lists (REPL, error messages).
Base.showarg(io::IO, A::AbstractAlternateVector, _) = print(io, typeof(A))

### Implementation of the array interface

# Returns the size (length) of the AlternateVector.
Base.size(A::AbstractAlternateVector) = (A.n,)

# Allows colon indexing to return the vector itself.
Base.getindex(x::AbstractAlternateVector, ::Colon) = x

# Broadcasting relation against other arrays

# Abstract type for broadcast styles specific to AlternateVector arrays.
abstract type AbstractArrayStyleAlternateVector <: Broadcast.AbstractArrayStyle{1} end

# Defines the broadcast style for AbstractArrayStyleAlternateVector and a Tuple broadcast style.
Base.BroadcastStyle(::AbstractArrayStyleAlternateVector, ::Base.Broadcast.Style{Tuple}) = Broadcast.DefaultArrayStyle{1}()

# Determines the broadcast style when combining AbstractArrayStyleAlternateVector with a DefaultArrayStyle of any dimension.
function Base.BroadcastStyle(a::AbstractArrayStyleAlternateVector, b::Broadcast.DefaultArrayStyle{N}) where {N}
    if (N > 0)
        return AlternateMixtureArrayStyle{N, Broadcast.DefaultArrayStyle{N}}()
    end
    return a
end

# Determines the broadcast style when combining AbstractArrayStyleAlternateVector with a general AbstractArrayStyle of any dimension.
function Base.BroadcastStyle(a::AbstractArrayStyleAlternateVector, b::T) where {T <: Broadcast.AbstractArrayStyle{N}} where {N}
    if (N > 0)
        return AlternateMixtureArrayStyle{N, T}()
    end
    return Base.BroadcastStyle(a, Broadcast.DefaultArrayStyle{0}())
end

# Materializes a broadcasted object if its style is AbstractArrayStyleAlternateVector.
function materialize_if_needed(bc::Base.Broadcast.Broadcasted{T, Nothing, <:F, <:R}) where {T <: AbstractArrayStyleAlternateVector, F, R}
    return Base.materialize(bc)
end

# Exclude Unknown broadcast style, using the second style as the fallback.
function exclude_unknown_style_if_possible(::Base.Broadcast.Unknown, style_1::V, style_2::U) where {V <: Base.Broadcast.BroadcastStyle, U <: Base.Broadcast.BroadcastStyle}
    Base.BroadcastStyle(style_2, style_1)
end

# Prefer the first style if it is not Unknown.
function exclude_unknown_style_if_possible(first::L, ::V, ::U) where {L <: Base.Broadcast.BroadcastStyle, V <: Base.Broadcast.BroadcastStyle, U <: Base.Broadcast.BroadcastStyle}
    first
end

# Optimization for broadcasting

# Represents a broadcast style that mixes two other broadcast styles.
abstract type AbstractAlternateMixtureArrayStyle{N} <: Broadcast.AbstractArrayStyle{N} end

struct AlternateMixtureArrayStyle{N, T} <: AbstractAlternateMixtureArrayStyle{N}
    # Construct from a single broadcast style.
    function AlternateMixtureArrayStyle{N, V}() where {V <: Broadcast.AbstractArrayStyle{N}} where {N}
        return new{N, V}()
    end
    function AlternateMixtureArrayStyle{V}() where {V <: Broadcast.AbstractArrayStyle{N}} where {N}
        return new{N, V}()
    end
    # Construct by mixing two broadcast styles, resolving Unknown if possible.
    function AlternateMixtureArrayStyle(style_1::V, style_2::U) where {V <: Base.Broadcast.BroadcastStyle, U <: Base.Broadcast.BroadcastStyle}
        style_implied_1 = Base.BroadcastStyle(style_1, style_2)
        style = exclude_unknown_style_if_possible(style_implied_1, style_1, style_2)
        return AlternateMixtureArrayStyle{typeof(style)}()
    end
end

function get_style(::AlternateMixtureArrayStyle{N, T}) where {T, N}
    return T()
end

# BroadcastStyle rules for AlternateMixtureArrayStyle

# Combine AlternateMixtureArrayStyle with a general AbstractArrayStyle.
function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, b::Broadcast.AbstractArrayStyle{N}) where {N}
    return AlternateMixtureArrayStyle(get_style(a), b)
end

# Combine AlternateMixtureArrayStyle with a DefaultArrayStyle.
function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, b::Broadcast.DefaultArrayStyle{N}) where {N}
    return AlternateMixtureArrayStyle(get_style(a), b)
end

# Combine two AlternateMixtureArrayStyle objects by mixing their sub-styles.
function Base.BroadcastStyle(a::AlternateMixtureArrayStyle, b::AlternateMixtureArrayStyle)
    return AlternateMixtureArrayStyle(get_style(a), get_style(b))
end

# Materialize broadcasted objects with AlternateMixtureArrayStyle.
function materialize_if_needed(bc::Base.Broadcast.Broadcasted{AlternateMixtureArrayStyle{N, T}, Nothing, <:F, <:R}) where {N, T, F, R}
    return Base.materialize(bc)
end

# Default: return object unchanged if materialization is not needed.
function materialize_if_needed(bc)
    return bc
end

# Materialize a broadcasted object with AlternateMixtureArrayStyle, materializing all arguments as needed.
function Base.materialize(bc::Base.Broadcast.Broadcasted{AlternateMixtureArrayStyle{N, T}, Nothing, <:F, <:R}) where {N, T, F, R}
    mat_args = materialize_if_needed.(bc.args)
    res = Base.materialize(Base.Broadcast.Broadcasted(get_style(bc.style), bc.f, mat_args))
    return res
end
