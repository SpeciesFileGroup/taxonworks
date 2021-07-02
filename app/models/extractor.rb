class Extractor < Role::ProjectRole

  has_many :extracts, inverse_of: :extractor_roles
  # has_many :determined_otus, through: :taxon_determinations, source: :otu
  # has_many :determined_biological_collection_objects, through: :taxon_determinations, source: :biological_collection_object

  def self.human_name
    'Extractor'
  end
end
