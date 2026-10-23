# Sort keys for ::TaxonNameRelationship, see Queries::Sort::Base.
class Queries::TaxonNameRelationship::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # `relationship` is the existing wire-format key for the STI `type`
      # column (auto-derived separately as 'type'); kept as an explicit
      # alias for backward compatibility.
      cols['relationship'] = direct(:type)

      cols['subject'] = association(:subject_taxon_name, :cached)
      cols['object'] = association(:object_taxon_name, :cached)

      cols
    end
  end
end
