class Role < ActiveRecord::Base

  belongs_to :role_object, polymorphic: :true
  acts_as_list scope: [ :role_object_id, :role_object_type]
  belongs_to :person

  # Note acts_as_list adds :position in a manner that it can not be validated with validate_presence_of
  validates_presence_of :person_id, :type, :role_object_id, :role_object_type 

end
