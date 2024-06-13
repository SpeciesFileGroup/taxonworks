class Determiner < Role::ProjectRole

  include Roles::Organization
  include Shared::DwcOccurrenceHooks

  has_one :taxon_determination, as: :role_object, inverse_of: :determiner_roles

  has_one :otu, through: :taxon_determination, source: :otu
  has_one :taxon_determination_object, through: :taxon_determination, source: :taxon_determination_object

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN taxon_determinations td on co.id = td.taxon_determination_object_id AND td.taxon_determination_object_type = 'CollectionObject'")
      .joins("JOIN roles r on r.type = 'Determiner' AND r.role_object_type = 'TaxonDetermination' AND r.role_object_id = td.id")
      .where(r: {id:})
      .distinct
  end

  def self.human_name
    'Determiner'
  end

  def year_active_year
    role_object.year_made
  end
end
