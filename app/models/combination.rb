class Combination < TaxonName

  has_many :combination_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'")},
    class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  %w{genus subgenus species subspecies}.each do |rank|
    has_one "#{rank}_taxon_name_relationship".to_sym, -> {
      joins(:combination_relationships)
      where(combination_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"} )},
    class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 

    has_one rank.to_sym, -> {
      joins( :combination_relationships)
      where( combination_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"} )  
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :object    
  end


end
