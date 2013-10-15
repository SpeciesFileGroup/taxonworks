class ::Chresonym < TaxonName

  has_many :chresonym_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Chresonym::%'")},
    class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  %w{genus subgenus species subspecies}.each do |rank|
    has_one "#{rank}_taxon_name_relationship".to_sym, -> {
      joins(:chresonym_relationships)
      where(chresonym_relationships: {type: "TaxonNameRelationship::Chresonym::#{rank.capitalize}"} )},
    class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 

    has_one rank.to_sym, -> {
      joins( :chresonym_relationships)
      where( chresonym_relationships: {type: "TaxonNameRelationship::Chresonym::#{rank.capitalize}"} )  
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :object    
  end


end
