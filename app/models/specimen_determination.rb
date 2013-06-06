class SpecimenDetermination < ActiveRecord::Base
  belongs_to :otu
  belongs_to :specimen
end
