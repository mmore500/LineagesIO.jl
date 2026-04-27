const StructureKeyType = Int
const OptionalString = Union{Nothing, String}
const EdgeWeightType = Union{Nothing, Float64}
const NodePropertyValueType = Union{StructureKeyType, OptionalString}
const EdgePropertyValueType = Union{StructureKeyType, EdgeWeightType, OptionalString}
