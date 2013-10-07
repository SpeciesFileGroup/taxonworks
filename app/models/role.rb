class Role < ActiveRecord::Base

  acts_as_list scope: [:role_object_type, :role_object_id]

  belongs_to :role_object, polymorphic: :true
  belongs_to :person

  validates_presence_of :person_id, :type, :role_object_id, :role_object_type, :position

end
