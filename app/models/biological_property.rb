class BiologicalProperty < ActiveRecord::Base

  include Housekeeping

  validates_presence_of :name, :definition
end
