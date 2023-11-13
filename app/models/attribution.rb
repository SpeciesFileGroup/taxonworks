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
  polymorphic_annotates('attribution_object', inverse_of: :attribution)

  # TODO: Consider DRYing with Source roles.

  has_many :roles, as: :role_object, dependent: :destroy

  ATTRIBUTION_ROLES = [
    :creator,
    :editor,
    :owner,
    :copyright_holder
  ].freeze

  ATTRIBUTION_ROLES.each do |r|
    role_name = "#{r}_roles".to_sym
    role_person = "attribution_#{r.to_s.pluralize}".to_sym
    role_organization = "attribution_organization_#{r.to_s.pluralize}".to_sym

    has_many role_name, -> { order('roles.position ASC') }, class_name: "Attribution#{r.to_s.camelize}", as: :role_object, inverse_of: :role_object
    has_many role_person, -> { order('roles.position ASC') }, through: role_name, source: :person, validate: true
    has_many role_organization, -> { order('roles.position ASC') }, through: role_name, source: :organization, validate: true

    accepts_nested_attributes_for role_name, allow_destroy: true
    accepts_nested_attributes_for role_person
    accepts_nested_attributes_for role_organization
  end

  validates_uniqueness_of :attribution_object_id, scope: [:attribution_object_type, :project_id]

  validates :license, inclusion: {in: CREATIVE_COMMONS_LICENSES.keys}, allow_nil: true

  validates :copyright_year, date_year: {
    min_year: 1000, max_year: Time.zone.now.year + 5,
    message: 'must be an integer greater than 999 and no more than 5 years in the future'}

  validate :some_data_provided

  protected

  def some_roles_present
    ATTRIBUTION_ROLES.each do |r|
      return true if send("#{r}_roles".to_sym).any?
    end

    if self.roles.any?
      self.roles.each do |r|
        return true if r.type.present? && r.person_id.present?
      end
    end

    false
  end

  def some_data_provided
    if license.blank? && copyright_year.blank? && !some_roles_present
      errors.add(:base, 'no attribution metadata')
    end
  end

end
