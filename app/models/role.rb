class Role < ActiveRecord::Base

  include Housekeeping

  acts_as_list scope: [ :role_object_id, :role_object_type, :type]

  belongs_to :role_object, polymorphic: :true
  belongs_to :person

  # Note acts_as_list adds :position in a manner that can not be validated with validate_presence_of
  validates_presence_of :person_id, :type, :role_object_id, :role_object_type 
  validates_uniqueness_of :person_id, scope: [:role_object_id, :role_object_type, :type]

end
