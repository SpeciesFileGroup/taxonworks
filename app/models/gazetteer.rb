# Gazetteer allows a project to add its own named shapes to participate in
# filtering, georeferencing, etc.
#
# @!attribute geography
#   @return [RGeo::Geographic::Geography]
#   Can hold any of the RGeo geometry types point, line string, polygon,
#   multipoint, multilinestring, multipolygon.
#
# @!attribute name
#   @return [String]
#   The name of the gazetteer item
#
# @!attribute parent_id
#   @return [Integer]
#   ???
#
# @!attribute iso_3166_a2
#   @return [String]
#   Two alpha-character identification of country.
#
# @!attribute iso_3166_a3
#   @return [String]
#   Three alpha-character identification of country.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID

class Gazetteer < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::DataAttributes
  include Shared::AlternateValues
  include Shared::IsData

  ALTERNATE_VALUES_FOR = [:name].freeze

  has_closure_tree

  belongs_to :geographic_item, inverse_of: :gazetteers

  validates :name, presence: true, length: {minimum: 1}

  accepts_nested_attributes_for :geographic_item

end
