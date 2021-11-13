class TaxonNameRelationship::Icn < TaxonNameRelationship

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000232'.freeze

  validates_uniqueness_of :subject_taxon_name_id, scope: [:type, :object_taxon_name_id]

  # left_side
  def self.valid_subject_ranks
    ::ICN
  end

  # right_side
  def self.valid_object_ranks
    ::ICN
  end

  def self.disjoint_subject_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICNP_TAXON_NAME_CLASSIFICATION_NAMES + ICVCN_TAXON_NAME_CLASSIFICATION_NAMES
  end

  def self.disjoint_object_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICNP_TAXON_NAME_CLASSIFICATION_NAMES +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def sv_validate_priority
    if self.type_class.nomenclatural_priority == :direct
      date1 = self.subject_taxon_name.nomenclature_date
      date2 = self.object_taxon_name.nomenclature_date
      if !!date1 && !!date2 && subject_invalid_statuses.empty?
        if TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).with_two_type_bases('TaxonNameRelationship::Icn::Accepting::Conserved', 'TaxonNameRelationship::Icn::Accepting::Sanctioned').not_self(self).empty?
          soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be older than #{self.object_status} #{self.object_taxon_name.cached_html_name_and_author_year}, unless it is also conserved or sanctioned name")
        end
      end
    end
  end
end
