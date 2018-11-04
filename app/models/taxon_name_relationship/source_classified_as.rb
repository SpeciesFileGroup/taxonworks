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

  # Shoudl be reversed!?
  def subject_status
    'as classified'
  end

  def object_status
    'classified'
  end

  def subject_status_connector_to_object
    ' for'
  end

  def object_status_connector_to_subject
    ' as'
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
    :reverse
  end

end
