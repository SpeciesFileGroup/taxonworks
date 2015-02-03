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
  include Shared::IsApplicationData

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

  def self.find_for_autocomplete(params)
    term = params[:term]
    terms = term.split
    limit = 100
    case term.length
      when 0..3
        limit = 10
      else
        limit = 40
    end

    search_term = terms.collect { |t| "name LIKE '#{t}%'" }.join(" OR ")
    self.where(name: term) + self.where(search_term).includes(:parent, :geographic_area_type).order('length(name)', :name).limit(limit)
  end

  # @param geographic_item [GeographicItem]
  # @return [Scope] of geographic_items
  def self.find_others_contained_by(geographic_area)
    pieces = GeographicItem.is_contained_by('any_poly', geographic_area.geo_object)
    pieces

    others = []
    pieces.each { |o|
      others.push(o.collecting_events_through_georeferences.to_a)
      others.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }
    pieces = CollectingEvent.where('id in (?)', others.flatten.map(&:id).uniq)

    pieces.excluding(geographic_area)

  end

  # @param geographic_item [GeographicItem]
  # @return [Scope] of geographic_items
  def self.find_others_contained_in(geographic_area)
    pieces = GeographicItem.is_contained_in('any', geographic_area.geo_object)
    pieces

    others = []
    pieces.each { |o|
      others.push(o.collecting_events_through_georeferences.to_a)
      others.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }
    pieces = CollectingEvent.where('id in (?)', others.flatten.map(&:id).uniq)

    pieces.excluding(geographic_area)

  end

  # @param latitude [Double] Decimal degrees
  # @param longitude [Double] Decimal degrees
  # @return [Scope] of all area which contain the point specified
  def self.find_by_lat_long(latitude = 0.0, longitude = 0.0)
    point = "POINT(#{longitude} #{latitude})"
    where_clause = "ST_Contains(polygon::geometry, GeomFromEWKT('srid=4326;#{point}')) OR ST_Contains(multi_polygon::geometry, GeomFromEWKT('srid=4326;#{point}'))"
    retval       = GeographicArea.joins(:geographic_items).where(where_clause)
    retval
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

  # @return [Hash] keys point to each of the four level components of the ID.  Matches values in original data.
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

  def default_geo_json
    default_geographic_item.to_geo_json2
  end

  def geo_object
    default_geographic_item
  end

  def to_geo_json_feature
    # object = self.geographic_items.order(:id).first
    #type = object.data_type?
   #if type == :geometry_collection
   #  geometry = RGeo::GeoJSON.encode(object)
   #else
      geo_id = self.geographic_items.order(:id).pluck(:id).first
      geometry = JSON.parse(GeographicItem.connection.select_all("select ST_AsGeoJSON(multi_polygon::geometry) geo_json from geographic_items where id=#{geo_id};")[0]['geo_json'])
   # end
    retval = {
      'type'       => 'Feature',
      'geometry'   => geometry,
      'properties' => {
        'geographic_area' => {
          'id' => self.id}
      }
    }
    retval
  end


  # Find a centroid by scaling this object tree up to the first antecedent which provides a geographic_item, and
  # provide a point on which to focus the map.  Return 'nil' if there are no GIs in the chain.
  def geographic_area_map_focus
    item = nil
    if geographic_items.count == 0
      # this nil signals the top of the stack: Everything terminates at 'Earth'
      unless parent.nil?
        item = parent.geographic_area_map_focus
      end
    else
      item = GeographicItem.new(point: geographic_items.first.st_centroid)
    end
    item
  end

  def geolocate_ui_params_hash
    # parameters = {county: level2.name, state: level1.name, country: level0.name}
    parameters           = {}
    parameters[:county]  = level2.name unless level2.nil?
    parameters[:state]   = level1.name unless level1.nil?
    parameters[:country] = level0.name unless level0.nil?
    item                 = geographic_area_map_focus
    unless item.nil?
      parameters[:Longitude] = item.point.x
      parameters[:Latitude]  = item.point.y
    end
    @geolocate_request = Georeference::GeoLocate::RequestUI.new(parameters)
    @geolocate_string  = @geolocate_request.request_params_string
    @geolocate_hash    = @geolocate_request.request_params_hash
  end

  # "http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?country=United States of America&state=Illinois&locality=Champaign&points=40.091622|-88.241179|Champaign|low|7000&georef=run|false|false|true|true|false|false|false|0&gc=Tester"
  def geolocate_ui_params_string
    if @geolocate_hash.nil?
      geolocate_ui_params_hash
    end
    @geolocate_string
  end

end
