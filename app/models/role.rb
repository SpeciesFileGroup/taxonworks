class Role < ActiveRecord::Base

  validates_presence_of :person_id, :type, :role_object_id, :role_object_type, :position

  belongs_to :person



end
