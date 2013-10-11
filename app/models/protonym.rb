class Protonym < TaxonName 

  belongs_to :original_description_source, foreign_key: :source_id, class_name: 'Source'

end
