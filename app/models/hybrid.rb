# A hybrid taxon, defined by adding relationships to this anonymous node.
#
# If only one name is asserted to be a hybrid (i.e. without reference to 
# multiple names) then this can be indicated 
# by creating a Protonym and applying the status of Hybrid.
# 
#
class Hybrid < TaxonName 

  has_many :hybrid_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Hybrid'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  validates_presence_of :rank_class, message: 'is a required field'

  soft_validate(:sv_hybrid_name_relationships, set: :hybrid_name_relationships)

  accepts_nested_attributes_for :hybrid_relationships

  def get_full_name_html
    hr = self.hybrid_relationships.reload
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached_html}.sort.join(' &#215; ')
  end

  def get_full_name
    hr = self.hybrid_relationships.reload
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached}.sort.join(' x ')
  end

  def set_cached_html
    self.cached_html = get_full_name_html
  end

  def set_cached
    self.cached = get_full_name
  end

  protected

  def validate_rank_class_class
    errors.add(:rank_class, 'It is not an ICN rank') unless ICN.include?(rank_string)
  end

  def sv_hybrid_name_relationships
    case hybrid_relationships.count
    when 0
      soft_validations.add(:base, 'Hybrid is not linked to non hybrid taxa')
    when 1
      soft_validations.add(:base, 'Hybrid should be linked to at least two non hybrid taxa')
    end
  end

end
