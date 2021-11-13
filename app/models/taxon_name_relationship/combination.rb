# The class relationships used to create Combinations.
class TaxonNameRelationship::Combination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type
  validate :subject_is_protonym

  # This is over-writing the assignment in taxon_name.rb, which restricts destroy.
  # In this case we want to destroy all the relationships.
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', 
    foreign_key: :object_taxon_name_id, 
    inverse_of: :object_taxon_name

  # @return [Integer, nil]
  def self.order_index
    RANKS.index(::ICN_LOOKUP[self.name.demodulize.underscore.humanize.downcase])
  end

#  def self.disjoint_classes
#    self.collect_descendants_to_s(TaxonNameClassification)
#  end

#  def self.disjoint_subject_classes
#    self.disjoint_classes
#  end

#  def self.disjoint_object_classes
#    self.disjoint_classes
#  end

  def self.nomenclatural_priority
    :reverse
  end

  # @return [String]
  #   the human readable rank this relationship pertains to
  def self.rank_name
    name.demodulize.humanize.downcase
  end

  def rank_name
    type_name.demodulize.humanize.downcase
  end

  # @return String
  #    the status inferred by the relationship to the object name 
  def object_status
    rank_name + ' in combination'
  end

  # @return String
  #    the status inferred by the relationship to the subject name 
  def subject_status
    ' as ' +  rank_name + ' in combination'
  end

  # @return String
  def subject_status_connector_to_object
    ''
  end

  # @return String
  def object_status_connector_to_subject
    ' with'
  end

  protected

  def set_cached_names_for_taxon_names
    begin
      TaxonName.transaction do
        t = object_taxon_name
        t.send(:set_cached)
      end
    end
    true
  end

  def subject_is_protonym
    errors.add(:subject_taxon_name, 'Must be a protonym') if subject_taxon_name.type == 'Combination'
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.nomenclature_date
    date2 = self.object_taxon_name.nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end

  def sv_coordinated_taxa_object
    true # not applicable
  end
end
