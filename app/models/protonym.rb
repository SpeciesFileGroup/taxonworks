class Protonym < TaxonName 

  alias_method :original_description_source, :source

  %w{genus subgenus species}.each do |rank|
    has_one "original_description_#{rank}_relationship".to_sym, -> {
      joins(:original_description_relationships)
      where(original_description_relationships: {type: "TaxonNameRelationship::OriginalDescription::Original#{rank.capitalize}"} )
    }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 

    has_one "original_#{rank}".to_sym, -> {
      joins( :original_description_relationships)
      where( original_description_relationships: {type: "TaxonNameRelationship::OriginalDescription::Original#{rank.capitalize}"} )  
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :object    
  end

  has_one :type_taxon_name_relationship, -> {
    joins(:original_description_relationships)
    limit(1)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id 
 
  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject

 # TODO: Not tested
 # has_many :type_of_relationships, -> {
 #   joins(:taxon_name_relationships)
 #   where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
 # },class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
 # 
 # has_many :type_of_taxon_names, through: :type_taxon_name_relationship, source: :object

  has_many :original_description_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::OriginalDescription::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

end
