class TaxonNameRelationship::Icvcn < TaxonNameRelationship

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000230'.freeze

  validates_uniqueness_of :subject_taxon_name_id, scope: [:type, :object_taxon_name_id]

  # left_side
  def self.valid_subject_ranks
    ::ICVCN
  end

  # right_side
  def self.valid_object_ranks
    ::ICVCN
  end

  def self.disjoint_subject_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNP_TAXON_NAME_CLASSIFICATION_NAMES
  end

  def self.disjoint_object_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icvcn::Invalid,
                                                 TaxonNameClassification::Icvcn::Valid::Unaccepted)
  end

end