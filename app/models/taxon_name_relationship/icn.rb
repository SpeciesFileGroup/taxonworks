class TaxonNameRelationship::Icn < TaxonNameRelationship

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000232'

  validates_uniqueness_of :subject_taxon_name_id, scope: [:type, :source_id, :object_taxon_name_id]

  # left_side
  def self.valid_subject_ranks
    ::ICN
  end

  # right_side
  def self.valid_object_ranks
    ::ICN
  end

  def self.disjoint_subject_classes
    ::ICZN
  end

  def self.disjoint_object_classes
    ::ICZN +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

end
