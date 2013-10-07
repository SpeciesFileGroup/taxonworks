class Role < ActiveRecord::Base

  belongs_to :has_roles, polymorphic: :true
  belongs_to :person

  validates_presence_of :person_id, :type, :role_object_id, :role_object_type #, :position

end
