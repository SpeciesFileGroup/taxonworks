class UnifyDestroyContext < ActiveSupport::CurrentAttributes
  # Set of {id:, type:} for objects currently being destroyed by an
  # in-flight (possibly nested) Shared::Unify#unify call. Populated by
  # #unify itself, before any related records are processed, so that
  # "must have at least one X" guards (e.g. Citation, TaxonDetermination)
  # can tell that an object they'd otherwise protect is already committed
  # to being destroyed regardless.
  attribute :objects_in_destroy
end
