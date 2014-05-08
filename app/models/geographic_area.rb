class GeographicArea < ActiveRecord::Base
  include Housekeeping::Users

  # TODO: Investigate how to do this unconditionally. Use rake NO_GEO_NESTING=1 ... to run incompatible tasks.
  acts_as_nested_set unless ENV['NO_GEO_NESTING']

  belongs_to :gadm_geo_item, class_name: 'GeographicItem', foreign_key: :gadm_geo_item_id
  belongs_to :geographic_area_type, inverse_of: :geographic_areas
  belongs_to :level0, class_name: 'GeographicArea', foreign_key: :level0_id
  belongs_to :level1, class_name: 'GeographicArea', foreign_key: :level1_id
  belongs_to :level2, class_name: 'GeographicArea', foreign_key: :level2_id
  belongs_to :ne_geo_item, class_name: 'GeographicItem', foreign_key: :ne_geo_item_id
  belongs_to :tdwg_geo_item, class_name: 'GeographicItem', foreign_key: :tdwg_geo_item_id
  belongs_to :tdwg_parent, class_name: 'GeographicArea', foreign_key: :tdwg_parent_id
  has_many :collecting_events, inverse_of: :geographic_area

  validates_presence_of :data_origin
  validates :name, presence: true, length: { minimum: 1 }
  validates :geographic_area_type, presence: true

  validates :level0, presence: true, unless: 'self.name == "Earth"', allow_nil: true
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true

  validates :parent, presence: true, unless: 'self.name == "Earth"'

  validates_uniqueness_of :name, scope: [:level0, :level1, :level2] unless ENV['NO_GEO_VALID']

  # TODO: still need to figure out why the validations of RGeo object associations fail.  These xxx_geo_item entry are commented out for this reason.
  #validates :ne_geo_item, presence: true, allow_nil: true
  #validates :gadm_geo_item, presence: true, allow_nil: true
  validates :tdwg_parent, presence: true, allow_nil: true
  #validates :tdwg_geo_item, presence: true, allow_nil: true

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

  def self.ancestors_and_descendants_of(geographic_area)
    where('(((geographic_areas.lft >= ?) AND (geographic_areas.lft <= ?)) OR
           ((geographic_areas.lft <= ?) AND (geographic_areas.rgt >= ?))) AND
           (geographic_areas.id != ?)',
        geographic_area.lft, geographic_area.rgt,
        geographic_area.lft, geographic_area.rgt,
        geographic_area.id).order(:lft)
  end

  # TODO: Test
  # Matches GeographicAreas that have name and parent name.
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
