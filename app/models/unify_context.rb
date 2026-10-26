# State an in-flight (possibly nested) Shared::Unify#unify call publishes for
# the callbacks and validations of related records it touches. Populated by
# #unify itself, before any related records are processed.
class UnifyContext < ActiveSupport::CurrentAttributes
  # Set of {id:, type:} for objects currently being destroyed by #unify, so
  # that "must have at least one X" guards (e.g. Citation, TaxonDetermination)
  # can tell that an object they'd otherwise protect is already committed to
  # being destroyed regardless.
  attribute :objects_in_destroy

  # Set of {id:, type:} for every remove_object currently being unified,
  # whether or not it will be destroyed (only:/except: unifies don't), so
  # that records may permit changes only #unify makes (e.g. matrix items
  # moving off of the object).
  attribute :objects_in_unify
end
