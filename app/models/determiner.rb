class Determiner < Role::ProjectRole

  include Roles::Organization

  has_many :taxon_determinations # this won't work
  has_many :determined_otus, through: :taxon_determinations, source: :otu
  has_many :determined_biological_collection_objects, through: :taxon_determinations, source: :biological_collection_object

  def self.human_name
    'Determiner'
  end

  def year_active_year
    role_object.year_made
  end
end
