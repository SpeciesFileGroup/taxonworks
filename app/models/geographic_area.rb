class GeographicArea < ActiveRecord::Base

  # acts_as_nested_set

  # internal references

  belongs_to :parent, class_name: "GeographicArea", foreign_key: :parent_id
  belongs_to :country, class_name: "GeographicArea", foreign_key: :country_id
  belongs_to :state, class_name: "GeographicArea", foreign_key: :state
  belongs_to :county, class_name: "GeographicArea", foreign_key: :county_id

  # external references

  belongs_to :geographic_item
  belongs_to :geographic_area_type
end
