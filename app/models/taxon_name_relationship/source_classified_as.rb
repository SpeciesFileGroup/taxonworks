# 
# Asserts that a Protonym or Combination (as subject) were classified under a particular parent (object)
#
#
# !! Subject/Object meaning was inverted. !! 
#
class TaxonNameRelationship::SourceClassifiedAs < TaxonNameRelationship

#  validates_uniqueness_of :subject_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    RANKS #  RANK_CLASS_NAMES
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_AND_ABOVE_RANK_NAMES
  end

  def self.disjoint_object_classes
    self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable,
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
        TaxonNameClassification::Icn::NotEffectivelyPublished)
  end

  def subject_status
    'classified'
  end

  def object_status
    'as classified'
  end

  def subject_status_connector_to_object
    ' as'
  end

  def object_status_connector_to_subject
    ' for'
  end

  # genus.source_classified_as = Family
  def self.assignment_method
    # :as_source_classified
    :source_classified_as
  end

  #family.as_source_classified_for = Genus
  def self.inverse_assignment_method
    :as_source_classified_for
  end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    nil
  end

  def sv_coordinated_taxa
    true
  end

  def sv_coordinated_taxa_object
    true # not applicable
  end

  def sv_validate_priority
    nil
#    date1 = self.subject_taxon_name.nomenclature_date
#    date2 = self.object_taxon_name.nomenclature_date
#    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
#      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
#    end
  end
end
