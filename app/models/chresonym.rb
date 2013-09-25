class Chresonym < TaxonName

  before_validation :check_for_at_least_on_taxon_name_relationship_of_type_chresonym

  # TODO: Abstract all this to a [:genus, :subgenus, :species, :subspecies] block
  has_one :genus, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chresonym::Genus"}, through: :genus_taxon_name_relationship, source: :object
  has_one :subgenus
  has_one :species, through: :genus_taxon_name_relationship, source: :object

# has_one :subspecies
 has_one :genus_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chresonym::Genus'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 
# has_one :subgenus_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chresonym::Subgenus'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 
# has_one :species_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chresonym::Species'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 
# has_one :subspecies_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chresonym::Subspecies'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 

  has_many :chresonym_relationships, -> {where "taxon_name_relationships.type LIKE 'TaxonNameRelationships::Chresonym::%'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  def genus=(value)
    self.taxon_name_relationships << TaxonNameRelationship.new(object: value, type: 'TaxonNameRelationship::Chresonym::Genus')
  end

  protected

  def check_for_at_least_on_taxon_name_relationship_of_type_chresonym
    # TODO: fix base error method
    errors.add(:base, 'chresonym has no names') if self.chresonym_relationships == []
  end

  def set_type_if_empty
    self.type = 'Chresonym' if self.type.nil?
  end



end
