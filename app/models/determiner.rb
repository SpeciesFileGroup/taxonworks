class Determiner < Role::ProjectRole

  include Roles::Organization

  has_one :taxon_determination, as: :role_object, inverse_of: :determiner_roles

  has_one :otu, through: :taxon_determination, source: :otu
  has_one :taxon_determination_object, through: :taxon_determination, source: :taxon_determination_object

  def self.human_name
    'Determiner'
  end

  def year_active_year
    role_object.year_made
  end
end
