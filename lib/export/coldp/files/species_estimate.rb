# SpeciesEstimate export for COLDP
#
# Exports estimated species counts stored as DataAttributes on OTUs,
# using Predicates with URIs from the ChecklistBank estimate type vocabulary.
#
# Claude Sonnet 4.6 provided > 50% of the code for this module.
#
module Export::Coldp::Files::SpeciesEstimate

  ESTIMATE_TYPE_MAP = {
    species_estimate_living:  'https://api.checklistbank.org/vocab/estimatetype#species_living',
    species_estimate_extinct: 'https://api.checklistbank.org/vocab/estimatetype#species_extinct',
    species_estimate_total:   'https://api.checklistbank.org/vocab/estimatetype#estimated_species'
  }.freeze

  # URI → COLDP type string
  ESTIMATE_TYPE_LABELS = {
    'https://api.checklistbank.org/vocab/estimatetype#species_living'    => 'species living',
    'https://api.checklistbank.org/vocab/estimatetype#species_extinct'   => 'species extinct',
    'https://api.checklistbank.org/vocab/estimatetype#estimated_species' => 'estimated species'
  }.freeze

  def self.data_attribute_scope(otus)
    DataAttribute
      .with(otu_scope: otus.unscope(:order).select(:id))
      .joins("JOIN otu_scope ON otu_scope.id = data_attributes.attribute_subject_id AND data_attributes.attribute_subject_type = 'Otu'")
      .joins(:predicate)
      .where(controlled_vocabulary_terms: { uri: ESTIMATE_TYPE_MAP.values })
  end

  def self.generate(otus, project_members, reference_csv = nil)
    da_scope = data_attribute_scope(otus)

    data_attributes = da_scope
      .left_joins(:citations)
      .select(
        'data_attributes.id',
        'data_attributes.attribute_subject_id',
        'data_attributes.value',
        'controlled_vocabulary_terms.uri AS predicate_uri',
        'data_attributes.updated_at',
        'data_attributes.updated_by_id',
        'MAX(citations.source_id) AS source_id'
      )
      .group(
        'data_attributes.id',
        'data_attributes.attribute_subject_id',
        'data_attributes.value',
        'controlled_vocabulary_terms.uri',
        'data_attributes.updated_at',
        'data_attributes.updated_by_id'
      )

    text = CSV.generate(col_sep: "\t") do |csv|
      csv << %w{
        taxonID
        sourceID
        estimate
        type
        referenceID
        remarks
        modified
        modifiedBy
      }

      data_attributes.find_each do |da|
        csv << [
          da.attribute_subject_id,                                  # taxonID
          nil,                                                      # sourceID
          da.value.to_i,                                            # estimate
          ESTIMATE_TYPE_LABELS[da.predicate_uri],                   # type
          da.source_id,                                             # referenceID
          nil,                                                      # remarks
          Export::Coldp.modified(da[:updated_at]),                   # modified
          Export::Coldp.modified_by(da[:updated_by_id], project_members) # modifiedBy
        ]
      end
    end

    sources = Source
      .with(da_scope:)
      .joins(:citations)
      .joins("JOIN da_scope ON da_scope.id = citations.citation_object_id AND citations.citation_object_type = 'DataAttribute'")
      .distinct

    Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv

    text
  end
end
