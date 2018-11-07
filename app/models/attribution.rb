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
#
class Attribution < ApplicationRecord
  include Housekeeping
  include Shared::Notes
  include Shared::Confidences
  include Shared::Tags
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('attribution_object')
  acts_as_list scope: [:attribution_object_id, :tag_object_type, :project_id]
  
  # TODO: Consider drying with Source roles.

  has_many :creator_roles, -> { order('roles.position ASC') }, class_name: 'AttributionCreator',
    as: :role_object, validate: true

  has_many :creators, -> { order('roles.position ASC') },
           through: :creator_roles, source: :person, validate: true

  has_many :editor_roles, -> { order('roles.position ASC') }, class_name: 'AttributionEditor',
    as: :role_object, validate: true

  has_many :editors, -> { order('roles.position ASC') },
           through: :editor_roles, source: :person, validate: true

  has_many :owner_roles, -> { order('roles.position ASC') }, class_name: 'AttributionOwner',
    as: :role_object, validate: true

  has_many :owners, -> { order('roles.position ASC') },
           through: :owner_roles, source: :person, validate: true

  validates :license, inclusion: {in: CREATIVE_COMMONS_LICENSES.keys}

  accepts_nested_attributes_for :editors, :creators, :creator_roles, :owner_roles, :editor_roles, allow_destroy: true

end
