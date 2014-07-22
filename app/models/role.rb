# A Role relates a Person (data in Taxonworks) with another data object.
#
class Role < ActiveRecord::Base

  acts_as_list scope: [ :type, :role_object_type, :role_object_id  ]

  belongs_to :role_object, polymorphic: :true
  belongs_to :person

  # Note acts_as_list adds :position in a manner that can not be validated with validate_presence_of
  validates_presence_of :person_id, :type, :role_object_id, :role_object_type 
  validates_uniqueness_of :person_id, scope: [:role_object_id, :role_object_type, :type]

  # This permits FactoryGirl testing using foo.collectors << @person type usage
  # it won't be needed, but shouldn't hurt, in production
  before_validation :set_creator_and_updater_from_person_if_possible

  protected

  def set_creator_and_updater_from_person_if_possible
    self.creator = self.person.creator if self.person && self.creator.nil?
    self.updater = self.person.updater if self.person && self.updater.nil?
  end

end
