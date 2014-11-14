# A GeographicArea is a gazeteer entry for some political subdivision. GeographicAreas are presently 
# limited to second level subdivisions (e.g. counties in the United States) or higher (i.e. state/country)
# * "Levels" are non-normalized values for convenience. 
#
# There are multiple hierarchies stored in GeographicArea (e.g. TDWG, GADM2).  Only when those 
# name "lineages" completely match are they merged.
#
# @!attribute name 
#   @return [String]
#     The name of the geographic area
# @!attribute level0_id
#   @return [Integer]
#     The id of the GeographicArea *country* that this geographic area belongs to, self.id if self is a country
# @!attribute level1_id
#   @return [Integer]
#     The id of the first level subdivision (starting from country) that this geographic area belongs to, self if self is a first level subdivision
# @!attribute level2_id
#   @return [Integer]
#     The id of the second level subdivision (starting from country) that this geographic area belongs to, self if self is a second level subdivision
# @!attribute parent_id
#   @return [Integer]
#     The id of the parent of this geographic area, will never be self, may be null (for Earth). Generally, sovereign countries have 'Earth' as parent.
# @!attribute geographic_area_type_id
#   @return [Integer]
#     The id of the type of this geographic area, index of geographic_area_types
# @!attribute iso_3166_a2
#   @return [String]
#     Two alpha-character identification of country.
# @!attribute iso_3166_a3
#   @return [String]
#     Three alpha-character identification of country.
# @!attribute tdwgID
#   @return [String]
#     If derived from the TDWG hierarchy the tdwgID.  Should be accessed through self#tdwg_ids, not directly.
# @!attribute data_origin
#   @return [String]
#     Text describing the source of the data used for creation (TDWG, GADM, NaturalEarth, etc.).
#
class GeographicArea < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps

  include Shared::IsData 

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
  has_many :geographic_areas_geographic_items, dependent: :destroy, inverse_of: :geographic_area
  has_many :geographic_items, through: :geographic_areas_geographic_items

  accepts_nested_attributes_for :geographic_areas_geographic_items

  validates :geographic_area_type, presence: true
  validates :parent, presence: true, unless: 'self.name == "Earth"' || ENV['NO_GEO_VALID']
  validates :level0, presence: true, allow_nil: true, unless: 'self.name == "Earth"'
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true

  validates_presence_of :data_origin
  validates :name, presence: true, length: {minimum: 1}

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

  scope :with_name_like, -> (string) { where(["name like ?", "#{string}%"]) }

  # A scope.
  def self.ancestors_and_descendants_of(geographic_area)
    where('(((geographic_areas.lft >= ?) AND (geographic_areas.lft <= ?)) OR
           ((geographic_areas.lft <= ?) AND (geographic_areas.rgt >= ?))) AND
           (geographic_areas.id != ?)',
          geographic_area.lft, geographic_area.rgt,
          geographic_area.lft, geographic_area.rgt,
          geographic_area.id).order(:lft)
  end

  # A scope. Matches GeographicAreas that have name and parent name.
  # Call via find_by_self_and_parents(%w{Champaign Illinois}).
  scope :with_name_and_parent_name, -> (names) {
    joins('join geographic_areas ga on ga.id = geographic_areas.parent_id').
      where(name: names[0]).
      where(['ga.name = ?', names[1]])
  }

  # TODO: Test, or extend a general method
  # Matches GeographicAreas that match name, parent name, parent.parent name.
  # Call via find_by_self_and_parents(%w{Champaign Illinois United\ States}).
  scope :with_name_and_parent_names, -> (names) {
    joins('join geographic_areas ga on ga.id = geographic_areas.parent_id').
      joins('join geographic_areas gb on gb.id = ga.parent_id').
      where(name: names[0]).
      where(['ga.name = ?', names[1]]).
      where(['gb.name = ?', names[2]])
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
      with_name_and_parent_names(array)
    else
      where { 'false' }
    end
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
     lvl2: self.tdwgID.slice(0, 2),
     lvl3: self.tdwgID.slice(2, 3),
     lvl4: self.tdwgID.slice(2, 6)
    }
  end

  def tdwg_level
    return nil if !self.data_origin =~ /TDWG/
    self.data_origin[-1]
  end

  def default_geographic_item
    # Postgis specific.
    retval = GeographicAreasGeographicItem.where(:geographic_area_id => self.id).order(
      "CASE data_origin
      WHEN 'ne_country' THEN 1
      WHEN 'ne_state' THEN 2
      WHEN 'gadm' THEN 3
      ELSE 4
      END, id"
    ).first.geographic_item
    retval
  end

  def geo_object
    default_geographic_item
  end

  def geolocate_params_string

  end

  def geolocate_params_hash

  end

  def self.find_for_autocomplete(params)
    terms = params[:term].split
    search_term = terms.collect{|t| "name LIKE '#{t}%'"}.join(" OR ") 
    where(search_term).includes(:parent, :geographic_area_type).order(:name)
  end

end
