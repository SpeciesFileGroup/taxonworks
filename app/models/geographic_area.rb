# A GeographicArea is a gazeteer entry for some political subdivision. GeographicAreas are presently 
# limited to second level subdivisions (e.g. counties in the United States) or higher (i.e. state/country)
# * "Levels" are non-normalized values for convenience. 
#
# There are multiple hierarchies stored in GeographicArea (e.g. TDWG, GADM2).  Only when those 
# name "lineages" completely match are they merged.
#
# @!attribute name 
#   @return [String]
#     the name of the geographic area 
# @!attribute level0_id
#   @return [Integer]
#     the id of the GeographicArea *country* that this geographic area belongs to, self.id if self is a country
# @!attribute level1_id
#   @return [Integer]
#     the id of the first level subdivision (starting from country) that this geographic area belongs to, self if self is a first level subdivision
# @!attribute level2_id
#   @return [Integer]
#     the id of the second level subdivision (starting from country) that this geographic area belongs to, self if self is a second level subdivision
# @!attribute tdwgID 
#   @return [String]
#     If derived from the TDWG hierarchy the tdwgID.  Should be accessed through self#tdwg_ids, not directly.


class GeographicArea < ActiveRecord::Base
  include Housekeeping::Users

  # TODO: Investigate how to do this unconditionally. Use rake NO_GEO_NESTING=1 ... to run incompatible tasks.
  if ENV['NO_GEO_NESTING']
    belongs_to :parent, class_name: GeographicArea, foreign_key: :parent_id
  else
    acts_as_nested_set 
  end

  belongs_to :geographic_area_type, inverse_of: :geographic_areas
  belongs_to :level0, class_name: 'GeographicArea', foreign_key: :level0_id
  belongs_to :level1, class_name: 'GeographicArea', foreign_key: :level1_id
  belongs_to :level2, class_name: 'GeographicArea', foreign_key: :level2_id
  
  has_many :collecting_events, inverse_of: :geographic_area
  has_many :geographic_areas_geographic_items, dependent: :destroy
  has_many :geographic_items, through: :geographic_areas_geographic_items

  validates :geographic_area_type, presence: true
  validates :parent, presence: true, unless: 'self.name == "Earth"' || ENV['NO_GEO_VALID']
  validates :level0, presence: true, allow_nil: true, unless: 'self.name == "Earth"'
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true
  
  validates_presence_of :data_origin
  validates :name, presence: true, length: { minimum: 1 }
  validates_uniqueness_of :name, scope: [:level0, :level1, :level2] unless ENV['NO_GEO_VALID']

  scope :descendants_of, -> (geographic_area) {
    where('(geographic_areas.lft >= ?) and (geographic_areas.lft <= ?) and
           (geographic_areas.id != ?)',
          geographic_area.lft, geographic_area.rgt,
          geographic_area.id).order(:lft) }
  scope :ancestors_of, -> (geographic_area) {
    where('(geographic_areas.lft <= ?) and (geographic_areas.rgt >= ?) and
           (geographic_areas.id != ?)',
          geographic_area.lft, geographic_area.rgt,
          geographic_area.id).order(:lft) }
  scope :ancestors_and_descendants_of, -> (geographic_area) {
    where('(((geographic_areas.lft >= ?) AND (geographic_areas.lft <= ?)) OR
           ((geographic_areas.lft <= ?) AND (geographic_areas.rgt >= ?))) AND
           (geographic_areas.id != ?)',
          geographic_area.lft, geographic_area.rgt,
          geographic_area.lft, geographic_area.rgt,
          geographic_area.id).order(:lft) }

  scope :with_name_like, -> (string) { where(["name like ?", "#{string}%"] ) } 

  # A scope.
  def self.ancestors_and_descendants_of(geographic_area)
    where('(((geographic_areas.lft >= ?) AND (geographic_areas.lft <= ?)) OR
           ((geographic_areas.lft <= ?) AND (geographic_areas.rgt >= ?))) AND
           (geographic_areas.id != ?)',
        geographic_area.lft, geographic_area.rgt,
        geographic_area.lft, geographic_area.rgt,
        geographic_area.id).order(:lft)
  end

  # TODO: Test
  # A scope. Matches GeographicAreas that have name and parent name.
  scope :with_name_and_parent_name, -> (names) {
    joins(:parent ).
    where(name: names[0], parent: {name: names[1]})
  }

  # TODO: Test, or extend a general method
  # Matches GeographicAreas that match name, parent name, parent name
  # Like:
  #   GeographicArea.with_name_and_parents(%{United\ States Illinois Champaign})
  scope :with_name_and_parents, -> (names) {
    joins(parent: :parent ).
    where(name: names[0].to_s, parent: {name: names[1].to_s, parent: {name: names[2] }}  )
  }

 # Route out to a scope given the length of the
  # search array.  Could be abstracted to 
  # build nesting on the fly if we actually
  # needed more than three nesting
 def self.find_by_self_and_parents(array)
   if array.length == 1
     where(name: array.first)
   elsif array.length == 2
     with_name_and_parent_name(array)
   elsif array.length == 3
     with_name_and_parents(array)
   else
     where { 'false' }
   end
 end

  # TODO: Test
  # Returns a scope of all _geo_items. 
  def geographic_items
    t = GeographicItem.arel_table
    GeographicItem.uniq.where(
      t[:id].eq(self.ne_geo_item_id).
      or(t[:id].eq(self.tdwg_geo_item_id)).
      or(t[:id].eq(self.gadm_geo_item_id))
    )
  end

  def self.countries
    includes([:geographic_area_type]).where(geographic_area_types: {name: 'Country'})
  end

  def children_at_level1
    GeographicArea.descendants_of(self).where('level1_id IS NOT NULL AND level2_id IS NULL')
  end

  def children_at_level2
    GeographicArea.descendants_of(self).where('level2_id IS NOT NULL')
  end

  def descendants_of_geographic_area_type(geographic_area_type)
    GeographicArea.descendants_of(self).includes([:geographic_area_type]).where(geographic_area_types: {name: geographic_area_type})
  end

  def descendants_of_geographic_area_types(geographic_area_types)
    GeographicArea.descendants_of(self).includes([:geographic_area_type]).where(geographic_area_types: {name: geographic_area_types})
  end

  # Returns a HASH with keys pointing to each of the four level components of the ID.  Matches values in original data.
  def tdwg_ids
    {lvl1: self.tdwgID.slice(0),
     lvl2: self.tdwgID.slice(0,2),
     lvl3: self.tdwgID.slice(2,3),
     lvl4: self.tdwgID.slice(2,6) 
    }
  end

  def tdwg_level
    return nil if !self.data_origin =~ /TDWG/
    self.data_origin[-1]
  end

  # priority:
  #   1)  NaturalEarth
  #   2)  GADM
  #   3)  TDWG
  def default_geographic_item
    geographic_items.order
   [ne_geo_item, gadm_geo_item, tdwg_geo_item].compact.first
  # retval = nil
  # if !ne_geo_item.nil?
  #   retval = ne_geo_item
  # else
  #   if !gadm_geo_item.nil?
  #     retval = gadm_geo_item
  #   else
  #     if !tdwg_geo_item.nil?
  #       retval = tdwg_geo_item
  #     else
  #       retval = nil
  #     end
  #   end
  # end
  # retval
  end

  def geo_object
    default_geographic_item
#   retval = default_geographic_item
#   retval.nil? ? nil : retval.geo_object
  end

end
