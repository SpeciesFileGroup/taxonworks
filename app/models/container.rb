class Container < ActiveRecord::Base
  acts_as_nested_set

  include Housekeeping
  include Shared::Identifiable
  include Shared::Containable

  has_many :physical_collection_objects

end
