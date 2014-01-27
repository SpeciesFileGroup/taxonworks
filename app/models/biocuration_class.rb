class BiocurationClass < ActiveRecord::Base

  include Housekeeping

  has_many :biocuration_classifications
  has_many :biological_objects

  validates_presence_of :name

end
