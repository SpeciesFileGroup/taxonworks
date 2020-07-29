class SpeciesFileRecord < ApplicationRecord
  self.abstract_class = true
 
  connects_to database: { writing: :onedb, reading: :onedb }
end