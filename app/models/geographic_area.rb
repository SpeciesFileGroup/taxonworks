class GeographicArea < ActiveRecord::Base

  # acts_as_nested_set

  # internal references

  belongs_to :parent, class_name: "GeographicArea", foreign_key: :parent_id
  belongs_to :tdwg_parent, class_name: "GeographicArea", foreign_key: :tdwg_parent_id
  belongs_to :level0, class_name: "GeographicArea", foreign_key: :level0_id
  belongs_to :level1, class_name: "GeographicArea", foreign_key: :level1_id
  belongs_to :level2, class_name: "GeographicArea", foreign_key: :level2_id

  # external references

  belongs_to :geographic_item
  belongs_to :geographic_area_type
end
