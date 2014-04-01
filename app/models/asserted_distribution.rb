class AssertedDistribution < ActiveRecord::Base
  belongs_to :otu
  belongs_to :geographic_area
  belongs_to :source
  belongs_to :project
end
