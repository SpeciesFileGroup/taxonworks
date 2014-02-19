class GeographicArea < ActiveRecord::Base

  include Housekeeping

  # acts_as_nested_set

  # internal references

  belongs_to :parent, class_name: "GeographicArea", foreign_key: :parent_id
  belongs_to :tdwg_parent, class_name: "GeographicArea", foreign_key: :tdwg_parent_id
  belongs_to :level0, class_name: "GeographicArea", foreign_key: :level0_id
  belongs_to :level1, class_name: "GeographicArea", foreign_key: :level1_id
  belongs_to :level2, class_name: "GeographicArea", foreign_key: :level2_id
  belongs_to :gadm_geo_item, class_name: "GeographicArea", foreign_key: :gadm_geo_item_id
  belongs_to :tdwg_geo_item, class_name: "GeographicArea", foreign_key: :tdwg_geo_item_id
  belongs_to :ne_geo_item, class_name: "GeographicArea", foreign_key: :ne_geo_item_id

  # external references

  belongs_to :geographic_item
  belongs_to :geographic_area_type, inverse_of: :geographic_areas

  # validations

  validates :name, presence: true
  validates :data_origin, presence: true

  validates :parent, presence: true, unless: 'self.name == "Earth"'
  validates :tdwg_parent, presence: true, allow_nil: true
  validates :level0, presence: true, unless: 'self.name == "Earth"'
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true
  validates :gadm_geo_item, presence: true, allow_nil: true
  validates :tdwg_geo_item, presence: true, allow_nil: true
  validates :ne_geo_item, presence: true, allow_nil: true

  end
