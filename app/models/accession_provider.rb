class AccessionProvider < Role::ProjectRole

  # has_many :taxon_determinations
  # has_many :determined_otus, through: :taxon_determinations, source: :otu
  # has_many :determined_objects, through: :taxon_determinations, source: :taxon_determination_object
  #
  # has_many :collection_objects

  def self.human_name
    'Accession provider'
  end

end
