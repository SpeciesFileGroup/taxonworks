# The (Role) person who created the georeference record.  If not include then assumed to be User or Source.
class Georeferencer  < Role::ProjectRole

  def self.human_name
    'Georeferencer'
  end

end
