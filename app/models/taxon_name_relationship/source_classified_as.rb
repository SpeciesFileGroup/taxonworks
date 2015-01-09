# 
# Asserts that a Protonym or Combination (as subject) were classified under a particular parent (object)
#
#
# !! Subject/Object meaning was inverted. !! 
#
class TaxonNameRelationship::SourceClassifiedAs < TaxonNameRelationship

  validates_uniqueness_of :subject_taxon_name_id, scope: :type

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
  def self.object_relationship_name
    'as classified for'
  end

  def self.subject_relationship_name
    'classified as'
  end

  # genus.source_classified_as = Family
  def self.assignment_method
    # :as_source_classified
    :source_classified_as
  end

    # inverse doesn't seem useful
    # #family.as_source_classified = Genus
    # def self.inverse_assignment_method
    #   :as_source_classified
    #   # :source_classified_as
    # end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    :reverse
  end

end
