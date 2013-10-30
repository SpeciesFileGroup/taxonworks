class TypeSpecimen < ActiveRecord::Base
  belongs_to :biological_object
  belongs_to :taxon_name

  has_many :type_designator_roles, class_name: 'Role::TypeDesignator', as: :role_object
  has_many :type_designators, through: :type_designator_roles, source: :person

end
