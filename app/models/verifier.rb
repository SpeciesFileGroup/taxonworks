# The (Role) person who created the georeference record.
class Georeferencer  < Role::ProjectRole

  def self.human_name
    'Georeferencer'
  end

end

# The (Role) person who is asserting that the data/properties/attributes of the Thing in question are correct, i.e. actionable in a useful [hopefully] scientific endeavour,
# according to their broader mental model and understanding of how those data/properties/attributes came to exist.
class Verifier  < Role::ProjectRole
  def self.human_name
    'Verifier'
  end
end
