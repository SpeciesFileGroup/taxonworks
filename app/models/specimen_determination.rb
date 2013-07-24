class SpecimenDetermination < ActiveRecord::Base
  belongs_to :otu
#  belongs_to :specimen
  belongs_to :specimen, class_name: 'Bar'
  validates_presence_of :otu, :specimen
end
