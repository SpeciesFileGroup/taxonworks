# Sort keys for ::Observation, see Queries::Sort::Base.
class Queries::Observation::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # Existing wire-format keys that don't match the underlying column names.
      cols['object_tag'] = direct(:cached)
      cols['type_label'] = direct(:type)

      # observation_object is a tag rendered in Ruby; sort on the taxon it
      # shows (see Queries::Sort::ObjectOtu).
      cols['observation_object'] = sort_by_object_otu_name(
        id_expr:   'observations.observation_object_id',
        type_expr: 'observations.observation_object_type',
        alias_prefix: 'sort_obs_object'
      )

      cols
    end
  end
end
