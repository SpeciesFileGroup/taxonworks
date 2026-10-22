# `sortable_columns` for Queries::Observation::Filter. Split out from
# filter.rb, same rationale as CollectionObject::SortableFilterColumns.
module Queries::Observation::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # Existing wire-format keys that don't match the underlying column names.
      cols['object_tag'] = direct(:cached)
      cols['type_label'] = direct(:type)

      # observation_object is a polymorphic type-dispatch display label
      # (Otu/CollectionObject/AnatomicalPart), not expressible via association().
      cols['observation_object'] = sort_by_polymorphic_object_tag(
        id_expr:   'observations.observation_object_id',
        type_expr: 'observations.observation_object_type',
        alias_prefix: 'sort_obs_object'
      )

      cols
    end
  end
end
