class Protonym < TaxonName 

  alias_method :original_description_source, :source

  # subject                      object
  # Aus      original_genus of   bus
  # aus      type_species of     Bus

  %w{genus subgenus species}.each do |rank|
    has_one "original_description_#{rank}_relationship".to_sym, class_name: "TaxonNameRelationship::OriginalDescription::Original#{rank.capitalize}", foreign_key: :object_taxon_name_id 
    has_one "original_description_#{rank}".to_sym, through: "original_description_#{rank}_relationship".to_sym, source: :subject
  end

  TaxonNameRelationship::Typification.descendants.each do |d|
    relationship = "#{d.assignment_method}_relationship".to_sym
    has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id 
    has_one d.assignment_method.to_sym, through: relationship, source: :subject
  end

  has_one :type_taxon_name_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id 
   
  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject



  has_many :type_of_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  has_many :type_of_taxon_names, through: :type_of_relationships, source: :object

  has_many :original_description_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::OriginalDescription::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

end
