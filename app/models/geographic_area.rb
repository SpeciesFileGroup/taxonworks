class GeographicArea < ActiveRecord::Base
  include Housekeeping::Users

  # acts_as_nested_set

  belongs_to :gadm_geo_item, class_name: 'GeographicItem', foreign_key: :gadm_geo_item_id
  belongs_to :geographic_area_type, inverse_of: :geographic_areas
  belongs_to :level0, class_name: 'GeographicArea', foreign_key: :level0_id
  belongs_to :level1, class_name: 'GeographicArea', foreign_key: :level1_id
  belongs_to :level2, class_name: 'GeographicArea', foreign_key: :level2_id
  belongs_to :ne_geo_item, class_name: 'GeographicItem', foreign_key: :ne_geo_item_id
  belongs_to :parent, class_name: 'GeographicArea', foreign_key: :parent_id
  belongs_to :tdwg_geo_item, class_name: 'GeographicItem', foreign_key: :tdwg_geo_item_id
  belongs_to :tdwg_parent, class_name: 'GeographicArea', foreign_key: :tdwg_parent_id

  validates_presence_of :data_origin
  validates_presence_of :name
  validates :geographic_area_type, presence: true

  validates :level0, presence: true, unless: 'self.name == "Earth"'
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true
  validates :parent, presence: true, unless: 'self.name == "Earth"'
  # TODO: still need to figure out why the validations of RGeo object associations fail.  These xxx_geo_item entry are commented out for this reason.
  #validates :ne_geo_item, presence: true, allow_nil: true
  #validates :gadm_geo_item, presence: true, allow_nil: true
  validates :tdwg_parent, presence: true, allow_nil: true
  #validates :tdwg_geo_item, presence: true, allow_nil: true

  scope :descendants_of, -> (geographic_area) {where('(geographic_areas.lft >= ?) and (geographic_areas.lft <= ?) and (geographic_areas.id != ?)', geographic_area.lft, geographic_area.rgt, geographic_area.id ).order(:lft)}
  scope :ancestors_of, -> (geographic_area) {where('(geographic_areas.lft <= ?) and (geographic_areas.rgt >= ?) and (geographic_areas.id != ?)', geographic_area.lft, geographic_area.rgt, geographic_area.id).order(:lft)}
  scope :ancestors_and_descendants_of, -> (geographic_area) {
    where('(((geographic_areas.lft >= ?) AND (geographic_areas.lft <= ?)) OR
           ((geographic_areas.lft <= ?) AND (geographic_areas.rgt >= ?))) AND
           (geographic_areas.id != ?)',
           geographic_area.lft, geographic_area.rgt, geographic_area.lft, geographic_area.rgt, geographic_area.id ).order(:lft) }

  def self.countries
    includes([:geographic_area_type]).where(geographic_area_types: {name: 'Country'})
  end

  def children_at_level1
    GeographicArea.descendants_of(self).where('level1_id IS NOT NULL AND level2_id IS NULL') 
  end

  def children_at_level2
    GeographicArea.descendants_of(self).where('level2_id IS NOT NULL') 
  end

  def descendents_of_geographic_area_type(geographic_area_type)
    GeographicArea.descendants_of(self).includes([:geographic_area_type]).where(geographic_area_types: {name: geographic_area_type})
  end

end
