class SpecimenDetermination < ActiveRecord::Base
  belongs_to :otu_id
  belongs_to :specimen_id
end
