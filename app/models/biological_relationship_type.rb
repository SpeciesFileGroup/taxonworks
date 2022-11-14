# A biological relationship type a domain or range assertion for a biological Relationship. 
#
# @!attribute type
#   @return [String]
#     Assigns to domain (subject), or range (object) 
#
# @!attribute biological_property_id
#   @return [Integer]
#     the property to assign 
#
# @!attribute biological_relationship_id
#   @return [Integer]
#     the relationship to assign it to 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalRelationshipType < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  belongs_to :biological_property, inverse_of: :biological_relationship_types
  belongs_to :biological_relationship, inverse_of: :biological_relationship_types

  validates_presence_of :type
  validates :biological_property, presence: true
  validates :biological_relationship, presence: true

  def target
    (self.type =~ /Subject/) ? 'subject' : 'object'
  end

end

Dir[Rails.root.to_s + '/app/models/biological_relationship_type/**/*.rb'].each { |file| require_dependency file }
