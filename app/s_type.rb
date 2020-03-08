# typed: strict
# frozen_string_literal: true

# Sorbet Type
module SType
  Array          = ::T.type_alias { T::Array[T.untyped] }
  Hash           = ::T.type_alias { T::Hash[String, T.untyped] }
  HashSymbol     = ::T.type_alias { T::Hash[Symbol, T.untyped] }
  ArrayOfHashes  = ::T.type_alias { T::Array[Hash] }
  NumberOrString = ::T.type_alias { T.any(String, Integer) }
end
