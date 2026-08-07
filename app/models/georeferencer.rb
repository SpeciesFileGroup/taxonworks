# The (Role) person who created the georeference record.
class Georeferencer  < Role::ProjectRole

  def self.human_name
    'Georeferencer'
  end

  def year_active_year
    role_object.year_georeferenced
  end

end

