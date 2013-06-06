class SpecimenDetermination < ActiveRecord::Base
  belongs_to :otu
  belongs_to :specimen

  validates_presence_of :otu, :specimen
end
