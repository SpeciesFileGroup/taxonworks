# CSV for for a ResourceRelationship based extension
# 
module Export::CSV::TaxonNameOrigin

  # NOT USED
  HEADERS = %w{
    id
    name
    original_name
  } + Source.column_names.freeze

  def self.csv(scope)
    q = ::TaxonName.with(tn_scope: scope.unscope(:select).select(:id))
      .joins('JOIN tn_scope ON tn_scope.id = taxon_names.id')
      .left_joins(:source)
      .select(
       "taxon_names.id as taxon_name_id", 
       "TRIM(CONCAT(taxon_names.cached, ' ', taxon_names.cached_author_year)) as name",
       "TRIM(CONCAT(taxon_names.cached_original_combination, ' ', taxon_names.cached_author_year)) as original_name",
       *Source.column_names.collect{|n| "sources.#{n}"}
      )

    ::Export::CSV.copy_table(q)
  end

end
