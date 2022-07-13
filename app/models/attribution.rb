# An attribution is an explicit assertion of who is responsible for different attributes of the content of tied data.
#
# @!attribute copyright_year 
#   @return [Integer]
#     4 digit year of copyright
#
# @!attribute license 
#   @return [String]
#     A creative-commons copyright 
#
class Attribution < ApplicationRecord
  include Housekeeping
  include Shared::Notes
  include Shared::Confidences
  include Shared::Tags
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('attribution_object')

  # TODO: Consider DRYing with Source roles.

  ATTRIBUTION_ROLES = [
    :creator,
    :editor,
    :owner,
    :copyright_holder
  ]

  ATTRIBUTION_ROLES.each do |r|
    role_name = "#{r}_roles".to_sym 
    role_person = "attribution_#{r.to_s.pluralize}".to_sym

    has_many role_name, -> { order('roles.position ASC') }, class_name: "Attribution#{r.to_s.camelize}", as: :role_object, validate: true
    has_many role_person, -> { order('roles.position ASC') }, through: role_name, source: :person, validate: true

    accepts_nested_attributes_for role_name, allow_destroy: true
    accepts_nested_attributes_for role_person 
  end

  validates_uniqueness_of :attribution_object_id, scope: [:attribution_object_type, :project_id]

  validates :license, inclusion: {in: CREATIVE_COMMONS_LICENSES.keys}, allow_nil: true

  validates :copyright_year, date_year: {min_year: 1000, max_year: Time.now.year + 5,
                                         message: 'must be an integer greater than 999 and no more than 5 years in the future'}

  validate :some_data_provided

  protected

  def some_data_provided
    errors.add(:base, 'no attribution metadata') if license.blank? && copyright_year.blank? && !editor_roles.any? && !creator_roles.any? && !owner_roles.any? && !roles.any?
  end

end
