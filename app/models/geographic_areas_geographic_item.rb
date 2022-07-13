# A GeographicAreaGeographicItem is an assertion that a
# GeographicArea was defined by a shape (GeographicItem) according to some source.
# The assertion may be bound by time.
#
# @!attribute geographic_area_id
#   @return [Integer]
#   The id of a GeographicArea that represents the area of this association.
#
# @!attribute geographic_item_id
#   @return [Integer]
#   The id of a GeographicItem that represents the geography of this association.
#
# @!attribute data_origin
#   @return [String]
#   The origin of this shape associations, take from SFGs /gaz data
#
# @!attribute origin_gid
#   @return [String]
#   The gid (row number) taken from the shape table from the source
#
# @!attribute date_valid_from
#   @return [String]
#   The verbatim value taken from the source data as to when this shape was first valid for the associated
#     GeographicArea (name)
#
# @!attribute date_valid_to
#   @return [String]
#   The verbatim data value taken from the source data as to when this shape was last valid for the associated
#     GeographicArea (name)
#
class GeographicAreasGeographicItem < ApplicationRecord
  include Shared::IsData
  include Shared::IsApplicationData

  belongs_to :geographic_area, inverse_of: :geographic_areas_geographic_items
  belongs_to :geographic_item, inverse_of: :geographic_areas_geographic_items

  validates :geographic_area, presence: true
  validates :geographic_item, presence: true unless ENV['NO_GEO_VALID']

  # # Postgis specific SQL
  # scope :ordered_by_data_origin, lambda {
  #   order(
  #     "CASE geographic_areas_geographic_items.data_origin
  #      WHEN 'ne_country' THEN 1
  #      WHEN 'ne_state' THEN 2
  #      WHEN 'gadm' THEN 3
  #      ELSE 4
  #      END"
  #   )
  # }
  #
  # https://github.com/DimaSavitsky/test-prototype/blob/df3c7c792331e19adfbb2065c7185623cabef24e/app/models/onet/occupation.rb#L61
  def self.ordered_by_data_origin
    order(origin_order_clause)
  end

  def self.origin_order_clause(table_alias = nil)
    t = arel_table
    t = t.alias(table_alias) if !table_alias.blank?

    c = Arel::Nodes::Case.new(t[:data_origin])
    c.when('ne_country').then(1)
    c.when('ne_state').then(2)
    c.when('gadm').then(3)
    c.else(4)
    c
  end

  def self.default_geographic_item_data
    q =  "WITH summary AS (
             SELECT p.id,
                    p.geographic_area_id,
                    p.geographic_item_id,
                    ROW_NUMBER() OVER(
                      PARTITION BY p.geographic_area_id
                      ORDER BY #{origin_order_clause('p').to_sql}) AS rk
             FROM geographic_areas_geographic_items p)
          SELECT s.*
            FROM summary s
            WHERE s.rk = 1"

    GeographicAreasGeographicItem.joins("JOIN (#{q}) as z ON geographic_areas_geographic_items.id = z.id")
  end

end
