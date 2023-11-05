module AlternateVectors
using Requires # for conditional dependencies
function __init__()
    @require CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba" include("deps/gpu_dependencies.jl")
end
include("alternate_vectors.jl")
include("alternate_padded_vectors.jl")
export AlternateVector, AlternatePaddedVector

end
