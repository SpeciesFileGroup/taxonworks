class Chrysonym < TaxonName


  # TODO: Abstract all this to a [:genus, :subgenus, :species, :subspecies] block
  has_one :genus, through: :genus_taxon_name_relationship, source: :object
  has_one :subgenus
  has_one :species
  has_one :subspecies
  has_one :genus_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chrysonym::Genus'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 
  has_one :subgenus_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chrysonym::Subgenus'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 
  has_one :species_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chrysonym::Species'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 
  has_one :subspecies_taxon_name_relationship, -> {where "taxon_name_relationships.type = 'TaxonNameRelationship::Chrysonym::Subspecies'"}, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 




end
