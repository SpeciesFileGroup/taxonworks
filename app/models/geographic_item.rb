require 'rgeo'

# A GeographicItem is one and only one of [point, line_string, polygon, multi_point, multi_line_string,
# multi_polygon, geometry_collection] which describes a position, path, or area on the globe, generally associated
# with a geographic_area (through a geographic_area_geographic_item entry), and sometimes only with a georeference.
#
# # @!attribute geo_object
#   @return [geographic RGeo object]
#     While no an attribute, per se, this instance method returns whatever sort of RGeo object it contains.  The actual
#     related column names we support are enumerated in the above description.
#     (See http://rubydoc.info/github/dazuma/rgeo/RGeo/Feature)
#
class GeographicItem < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData
  include Shared::SharedAcrossProjects

  # an internal variable for use in super calls, holds a geo_json hash (temporarily)
  attr_accessor :geometry
  attr_accessor :shape

  LAT_LON_REGEXP = Regexp.new(/(?<lat>-?\d+\.?\d*),?\s*(?<lon>-?\d+\.?\d*)/)

  DATA_TYPES = [:point,
                :line_string,
                :polygon,
                :multi_point,
                :multi_line_string,
                :multi_polygon,
                :geometry_collection]

  column_factory = Gis::FACTORY
  DATA_TYPES.each do |t|
    set_rgeo_factory_for_column(t, column_factory)
  end

  # validates_uniquness_of if !.blank.

  has_many :geographic_areas_geographic_items, dependent: :destroy, inverse_of: :geographic_item
  has_many :geographic_areas, through: :geographic_areas_geographic_items

  has_many :gadm_geographic_areas, class_name: 'GeographicArea', foreign_key: :gadm_geo_item_id
  has_many :ne_geographic_areas, class_name: 'GeographicArea', foreign_key: :ne_geo_item_id
  has_many :tdwg_geographic_areas, class_name: 'GeographicArea', foreign_key: :tdwg_geo_item_id

  has_many :georeferences
  has_many :georeferences_through_error_geographic_item, class_name: 'Georeference', foreign_key: :error_geographic_item_id

  has_many :collecting_events_through_georeferences, through: :georeferences, source: :collecting_event
  has_many :collecting_events_through_georeference_error_geographic_item, through: :georeferences_through_error_geographic_item, source: :collecting_event

  before_validation :set_type_if_geography_present

  validates_presence_of :type
  validate :some_data_is_provided

  scope :include_collecting_event, -> { includes(:collecting_events_through_georeferences) }
  scope :geo_with_collecting_event, -> { joins(:collecting_events_through_georeferences) }
  scope :err_with_collecting_event, -> { joins(:georeferences_through_error_geographic_item) }

  # return [Scope]
  #   A scope that limits the result to those GeographicItems that have a collecting event
  #   through either the geographic_item or the error_geographic_item
  #
  # A raw SQL join approach for comparison
  #
  # GeographicItem.joins('LEFT JOIN georeferences g1 ON geographic_items.id = g1.geographic_item_id').
  #   joins('LEFT JOIN georeferences g2 ON geographic_items.id = g2.error_geographic_item_id').
  #   where("(g1.geographic_item_id IS NOT NULL OR g2.error_geographic_item_id IS NOT NULL)").uniq

  # @return [Scope] GeographicItem
  # This uses an Arel table approach, this is ultimately more decomposable if we need. Of use:
  #  http://danshultz.github.io/talks/mastering_activerecord_arel  <- best
  #  https://github.com/rails/arel
  #  http://stackoverflow.com/questions/4500629/use-arel-for-a-nested-set-join-query-and-convert-to-activerecordrelation
  #  http://rdoc.info/github/rails/arel/Arel/SelectManager
  #  http://stackoverflow.com/questions/7976358/activerecord-arel-or-condition
  #
  def self.with_collecting_event_through_georeferences
    geographic_items = GeographicItem.arel_table
    georeferences    = Georeference.arel_table
    g1               = georeferences.alias('a')
    g2               = georeferences.alias('b')

    c = geographic_items.join(g1, Arel::Nodes::OuterJoin).on(geographic_items[:id].eq(g1[:geographic_item_id])).
      join(g2, Arel::Nodes::OuterJoin).on(geographic_items[:id].eq(g2[:error_geographic_item_id]))

    GeographicItem.joins(# turn the Arel back into scope
      c.join_sources # translate the Arel join to a join hash(?)
    ).where(
      g1[:id].not_eq(nil).or(g2[:id].not_eq(nil)) # returns a Arel::Nodes::Grouping
    ).distinct
  end

  # @return [Scope]
  #   includes an 'is_valid' attribute (True/False) for the passed geographic_item.  Uses St_IsValid.
  def self.with_is_valid_geometry_column(geographic_item)
    where(id: geographic_item.id).select("ST_IsValid(#{geographic_item.st_as_binary_sql}) is_valid")
  end

  # @return [Boolean]
  #   whether stored shape is ST_IsValid
  def is_valid_geometry?
    GeographicItem.with_is_valid_geometry_column(self).first['is_valid']
  end

  # @return [Integer]
  #   the number of points in the geometry
  def st_npoints
    GeographicItem.where(id: self.id).pluck("ST_NPoints(#{self.geo_object_type}::geometry)").first
  end

  # @return [Array of GeographicArea]
  #   the parents of the geographic areas
  # TODO: this should likely be a has_many :through relation
  def parent_geographic_areas
    self.geographic_areas.collect { |a| a.parent }
  end

  # @return [Array of GeographicArea]
  def parents_through_geographic_areas
    result = {}
    parent_geographic_areas.collect { |a|
      result.merge!(a => a.geographic_items)
    }
    result
  end

  # @return [Array of GeographicArea]
  def children_through_geographic_areas
    result = {}
    geographic_areas.collect { |a|
      a.children.collect { |c|
        result.merge!(c => c.geographic_items)
      }
    }
    result
  end

  # Moved to subclass code
  # def st_start_point
  # end

  # @return [Array of latitude, longitude]
  #    the lat, lon of the first point in the GeoItem
  def start_point
    o = st_start_point
    [o.y, o.x]
  end

  # @return [String]
  #   a WKT POINT representing the centroid of the geographic item
  def st_centroid
    GeographicItem.where(id: self.to_param).pluck("ST_AsEWKT(ST_Centroid(#{self.geo_object_type}::geometry))").first.gsub(/SRID=\d*;/, '')
  end

  # @return [Array]
  #   the lat, long, as STRINGs for the centroid of this geographic item
  def center_coords
    result = st_centroid.match(LAT_LON_REGEXP)
    [result['lat'], result['lon']]
  end

  # @return [String]
  #   a SQL fragment for ST_AsBinary
  def st_as_binary_sql
    "ST_AsBinary(#{self.geo_object_type})"
  end

  # @return [String]
  #   a SQL fragment for ST_GeomFromEWKB, you should use column::geometry casting, not this
  def to_geometry_sql
    "ST_GeomFromEWKB(#{self.geo_object_type})"
  end

=begin
SELECT round(CAST(
    ST_Distance_Spheroid(ST_Centroid(the_geom), ST_GeomFromText('POINT(-118 38)',4326), 'SPHEROID["WGS 84",6378137,298.257223563]')
      As numeric),2) As dist_meters_spheroid

 dist_meters_spheroid | dist_meters_sphere | dist_utm11_meters
----------------------+--------------------+-------------------
       70454.92 |           70424.47 |          70438.00

=end

  # @return [String(?)]
  #   distance in meters from this object to supplied 'geo_object'
  # TODO: use a geographic_item_id rather than a geo_object
  def st_distance(geo_object)
    GeographicItem.where(id: self.id).pluck("ST_Distance_Spheroid('#{self.geo_object}','#{geo_object}','#{Gis::SPHEROID}') as distance").first
  end

=begin
  scope :intersecting_boxes, -> (column_name, geographic_item) {
    select("ST_Contains(geographic_items.#{column_name}, #{geographic_item.geo_object})",
    ) }

  def self.same(geo_object_a, geo_object_b)
    # http://postgis.refractions.net/documentation/manual-1.4/ST_Geometry_Same.html
    # boolean ~=( geometry A , geometry B );
    # TODO: not sure how to specify '~=', syntactically substituting 'same'
    where(st_geometry_same(geo_object_a, geo_object_b))
    # returns true if the two objects are, vertex-by-vertex, the same
  end

  def self.area(geo_polygon) # or multi_polygon
    # http://postgis.refractions.net/documentation/manual-1.4/ST_Area.html
    # float ST_Area(geometry g1);
    where(st_area(geo_polygon))
    # returns the area area of the geometry as a float
  end

  def self.azimuth(geo_point_a, geo_point_b)
    # http://postgis.refractions.net/documentation/manual-1.4/ST_Azimuth.html
    # float ST_Azimuth(geometry pointA, geometry pointB);
    where(st_azimuth(geo_point_a, geo_point_b))
  end

  def self.centroid(geo_object)
    # http://postgis.refractions.net/documentation/manual-1.4/ST_Centroid.html
    # geometry ST_Centroid(geometry g1);
    where(st_centroid(geo_object))
    # returns a point
  end

  def self.find_containing(column_name, geo_object)
    # ST_Contains(geometry, geometry) or
    # ST_Contains(geography, geography)
    where{st_contains(st_geomfromewkb(column_name), geo_object)}
  end
=end


  # @return [Scope]
  #
  # See comments https://groups.google.com/forum/#!topic/postgis-users/0nzm2SRUZVU on why this might not work
  # For the record: the problem was caused by incorrect escaping of strings.
  # I solved it by setting standard_conforming_strings = off in postgresql.conf
  # TODO: @mjy: Do you think this is a permanent change in PG configuration?
  def self.contains?(geo_object_a, geo_object_b)
    # ST_Contains(geometry, geometry) or
    # ST_Contains(geography, geography)
    where { st_contains(st_geomfromewkb(geo_object_a), st_geomfromewkb(geo_object_b)) }
  end

  # TODO(?): as per http://danshultz.github.io/talks/mastering_activerecord_arel/#/7/1
  class << self
    # @param [String, GeographicItems]
    # @return [Scope]
    def intersecting(column_name, *geographic_items)
      if column_name.downcase == 'any'
        pieces = []
        DATA_TYPES.each { |column|
          pieces.push(GeographicItem.intersecting("#{column}", geographic_items).to_a)
        }

        # todo: change 'id in (?)' to some other sql construct

        GeographicItem.where(id: pieces.flatten.map(&:id))
      else
        q = geographic_items.flatten.collect { |geographic_item|
          "ST_Intersects(#{column_name}, '#{geographic_item.geo_object}'    )" # seems like we want this: http://danshultz.github.io/talks/mastering_activerecord_arel/#/15/2
        }.join(' or ')

        where(q)
      end
    end

    # @param [String, Geometry]
    # @return [Scope]
    # TODO: not used?
    def st_intersects(column_name = :multi_polygon, geometry)
      geographic_item = GeographicItem.arel_table
      Arel::Nodes::NamedFunction.new('ST_Intersects', geographic_item[column_name], geometry)
    end
  end # class << self

  # @param [String, GeographicItem, Double]
  # @return [Scope]
  #   distance is measured in meters
  def self.within_radius_of(column_name, geographic_item, distance) # ultimately it should be geographic_item_id
    if column_name.downcase == 'any'
      pieces = []

      DATA_TYPES.each { |column|
        pieces.push(GeographicItem.within_radius_of("#{column}", geographic_item, distance))
      }

      GeographicItem.where(id: pieces.flatten.map(&:id))
    else
      if check_geo_params(column_name, geographic_item)
        where("st_distance(#{column_name}, (#{select_geography_sql(geographic_item.to_param, geographic_item.geo_object_type)})) < #{distance}")
      else
        where("false")
      end
    end
  end

  def self.within_radius_of_object(column_name, geometry, distance)
    if column_name.downcase == 'any'
      pieces = []

      DATA_TYPES.each { |column|
        pieces.push(GeographicItem.within_radius_of("#{column}", geometry, distance))
      }

      GeographicItem.where(id: pieces.flatten.map(&:id))
    else
      if check_geo_params(column_name, geographic_item)
        where("st_distance(#{column_name}, (#{select_geography_sql(geometry, geographic_item.geo_object_type)})) < #{distance}")
      else
        where("false")
      end
    end
  end

  # @param [Integer, String]
  # @return [String]
  #   a SQL select statement that returns the geography for the geographic_item with the specified id
  def self.select_geography_sql(geographic_item_id, geo_object_type)
    "SELECT #{geo_object_type} from geographic_items where id = #{geographic_item_id}"
  end

  # @param [String, GeographicItem]
  # @return [String]
  #   a SQL fragment for ST_DISJOINT, specifies all geographic_items that have data in column_name
  #   that are disjoint from the passed geographic_items
  def self.disjoint_from(column_name, *geographic_items)
    q = geographic_items.flatten.collect { |geographic_item|
      "ST_DISJOINT(#{column_name}::geometry, (#{geometry_sql(geographic_item.to_param, geographic_item.geo_object_type)}))"
    }.join(' and ')
    where (q)
  end

  # @param [String] name of column to search
  # @param [GeographicItem] item or array of geographic_item containing result
  # @return [Scope]
  #
  # If this scope is given an Array of GeographicItems as a second parameter,
  # it will return the 'or' of each of the objects against the table.
  # SELECT COUNT(*) FROM "geographic_items"  WHERE (ST_Contains(polygon::geometry, GeomFromEWKT('srid=4326;POINT (0.0 0.0 0.0)')) or ST_Contains(polygon::geometry, GeomFromEWKT('srid=4326;POINT (-9.8 5.0 0.0)')))
  def self.are_contained_in(column_name, *geographic_items)
    column_name.downcase!
    case column_name
      when 'any'
        part = []
        DATA_TYPES.each { |column|
          unless column == :geometry_collection
            part.push(GeographicItem.are_contained_in("#{column}", geographic_items).to_a)
          end
        }
        # todo: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten.map(&:id))
      when 'any_poly', 'any_line'
        part = []
        DATA_TYPES.each { |column|
          if column.to_s.index(column_name.gsub('any_', ''))
            part.push(GeographicItem.are_contained_in("#{column}", geographic_items).to_a)
          end
        }
        # todo: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten.map(&:id))
      else
        q = geographic_items.flatten.collect { |geographic_item|
          GeographicItem.containing_sql(column_name, geographic_item.id, geographic_item.geo_object_type)
        }.join(' or ')
        where(q) # .excluding(geographic_items)
    end
  end

  # @param [String] column_name
  # @param [String] geometry of WKT
  # @return [Scope]
  # a single WKT geometry is compared against column or columns (except geometry_collection) to find geographic_items
  # which are contained in the WKT
  def self.are_contained_in_object(column_name, geometry)
    column_name.downcase!
    # column_name = 'point'
    case column_name
      when 'any'
        part = []
        DATA_TYPES.each { |column|
          unless column == :geometry_collection
            part.push(GeographicItem.are_contained_in_object("#{column}", geometry).to_a)
          end
        }
        # todo: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten.map(&:id))
      when 'any_poly', 'any_line'
        part = []
        DATA_TYPES.each { |column|
          if column.to_s.index(column_name.gsub('any_', ''))
            part.push(GeographicItem.are_contained_in_object("#{column}", geometry).to_a)
          end
        }
        # todo: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten.map(&:id))
      else
        # column = points, geometry = square
        q = "ST_Contains(ST_GeomFromEWKT('srid=4326;#{geometry}'), #{column_name}::geometry)"
        where(q) # .excluding(geographic_items)
    end

  end

  # @return [Scope]
  #    containing the items the shape of which is contained in the geographic_item[s] supplied.
  # @param column_name [String] can be any of DATA_TYPES, or 'any' to check against all types, 'any_poly' to check against 'polygon' or 'multi_polygon', or 'any_line' to check against 'line_string' or 'multi_line_string'.  CANNOT be 'geometry_collection'.
  # @param geographic_items [GeographicItem] Can be a single GeographicItem, or an array of GeographicItem.
  def self.is_contained_by(column_name, *geographic_items)
    column_name.downcase!
    case column_name
      when 'any'
        part = []
        DATA_TYPES.each { |column|
          unless column == :geometry_collection
            part.push(GeographicItem.is_contained_by("#{column}", geographic_items).to_a)
          end
        }
        # todo: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten.map(&:id))

      when 'any_poly', 'any_line'
        part = []
        DATA_TYPES.each { |column|
          unless column == :geometry_collection
            if column.to_s.index(column_name.gsub('any_', ''))
              part.push(GeographicItem.is_contained_by("#{column}", geographic_items).to_a)
            end
          end
        }
        # todo: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten.map(&:id))

      else
        q = geographic_items.flatten.collect { |geographic_item|
          GeographicItem.containing_sql_reverse(column_name, geographic_item.to_param, geographic_item.geo_object_type)
        }.join(' or ')
        where(q) # .excluding(geographic_items)
    end
  end

  # @param [String, GeographicItem]
  # @return [Scope]
  def self.ordered_by_shortest_distance_from(column_name, geographic_item)
    if check_geo_params(column_name, geographic_item)
      q = select_distance_with_geo_object(column_name, geographic_item).where_distance_greater_than_zero(column_name, geographic_item).order('distance')
      q
    else
      where ('false')
    end
  end

  # @param [String, GeographicItem]
  # @return [Scope]
  def self.ordered_by_longest_distance_from(column_name, geographic_item)
    if check_geo_params(column_name, geographic_item)
      q = select_distance_with_geo_object(column_name, geographic_item).
        where_distance_greater_than_zero(column_name, geographic_item).
        order('distance desc')
      q
    else
      where ('false')
    end
  end

  # @param [String, Integer, String]
  # @return [String]
  #   a SQL fragment for ST_Contains() function, returns
  #   all geographic items which are contained in the item supplied
  def self.containing_sql(target_column_name = nil, geographic_item_id = nil, source_column_name = nil)
    return 'false' if geographic_item_id.nil? || source_column_name.nil? || target_column_name.nil?
    "ST_Contains(#{target_column_name}::geometry, (#{geometry_sql(geographic_item_id, source_column_name)}))"
  end

  # @param [String, Integer, String]
  # @return [String]
  #   a SQL fragment for ST_Contains(), returns
  #   all geographic_items which contain the supplied geographic_item
  def self.containing_sql_reverse(target_column_name = nil, geographic_item_id = nil, source_column_name = nil)
    return 'false' if geographic_item_id.nil? || source_column_name.nil? || target_column_name.nil?
    "ST_Contains((#{geometry_sql(geographic_item_id, source_column_name)}), #{target_column_name}::geometry)"
  end

  # @param [Integer, String]
  # @return [String]
  #   a SQL fragment that represents the geometry of the geographic item specified (which has data in the source_column_name, i.e. geo_object_type)
  def self.geometry_sql(geographic_item_id = nil, source_column_name = nil)
    return 'false' if geographic_item_id.nil? || source_column_name.nil?
    "select geom_alias_tbl.#{source_column_name}::geometry from geographic_items geom_alias_tbl where geom_alias_tbl.id = #{geographic_item_id}"
  end

  #def self.select_distance(column_name, geographic_item)
  #  # select { "ST_Distance(#{column_name}, GeomFromEWKT('srid=4326;#{geographic_item.geo_object}')) as distance" }
  #  select(" ST_Distance(#{column_name}, GeomFromEWKT('srid=4326;#{geographic_item.geo_object}')) as distance")
  #end

  # @param [String, GeographicItem]
  # @return [String]
  def self.select_distance_with_geo_object(column_name, geographic_item)
    select("*, ST_Distance(#{column_name}, GeomFromEWKT('srid=4326;#{geographic_item.geo_object}')) as distance")
  end

  # @param [String, GeographicItem]
  # @return [Scope]
  def self.where_distance_greater_than_zero(column_name, geographic_item)
    where("#{column_name} is not null and ST_Distance(#{column_name}, GeomFromEWKT('srid=4326;#{geographic_item.geo_object}')) > 0")
  end

  # @param [GeographicItem]
  # @return [Scope]
  def self.excluding(geographic_items)
    where.not(id: geographic_items)
  end

  # @param [String] type_name ('polygon', 'point', 'line' [, 'circle'])
  # @return [String] if type
  def self.eval_for_type(type_name)
    retval = "GeographicItem"
    case type_name.upcase
      when 'POLYGON'
        retval += '::Polygon'
      when 'LINESTRING'
        retval += '::LineString'
      when 'POINT'
        retval += '::Point'
      when 'MULTIPOLYGON'
        retval += '::MultiPolygon'
      when 'MULTILINESTRING'
        retval += '::MultiLineString'
      when 'MULTIPOINT'
        retval += '::MultiPoint'
      else
        retval = nil
    end
    retval
  end

  # instance methods

  # @return [Scope]
  def excluding_self
    where.not(id: self.id)
  end

  # @return [Symbol]
  #   the geo type (i.e. column like :point, :multipolygon).  References the first-found object, according to the list of DATA_TYPES, or nil
  def geo_object_type
    if self.class.name == 'GeographicItem' # a proxy check for new records
      geo_type
    else
      self.class::SHAPE_COLUMN
    end
  end

  # @return [RGeo instance, nil]
  #    the Rgeo shape
  def geo_object
    if r = geo_object_type
      self.send(r)
    else
      false
    end
  end

  # Methods mapping RGeo methods

  # @param [geo_object]
  # @return [Boolean]
  def contains?(geo_object)
    self.geo_object.contains?(geo_object)
  end

  # @param [geo_object]
  # @return [Boolean]
  def within?(geo_object)
    self.geo_object.within?(geo_object)
  end

  # TODO: doesn't work?
  # @param [geo_object]
  # @return [Boolean]
  def distance?(geo_object)
    self.geo_object.distance?(geo_object)
  end

  # @param [geo_object, Double]
  # @return [Boolean]
  def near(geo_object, distance)
    self.geo_object.buffer(distance).contains?(geo_object)
  end

  # @param [geo_object, Double]
  # @return [Boolean]
  def far(geo_object, distance)
    !self.near(geo_object, distance)
  end

  # @return [GeoJSON hash]
  #    via Rgeo apparently necessary for GeometryCollection
  def rgeo_to_geo_json
    RGeo::GeoJSON.encode(self.geo_object).to_json
  end

  # @return [GeoJSON hash]
  #   raw Postgis (much faster)
  def to_geo_json
    JSON.parse(GeographicItem.connection.select_all("select ST_AsGeoJSON(#{self.geo_object_type.to_s}::geometry) a from geographic_items where id=#{self.id};").first['a'])
  end

  # @return [GeoJSON Feature] the shape as a GeoJSON Feature
  def to_geo_json_feature
    @geometry ||= to_geo_json
    {
      'type'       => 'Feature',
      'geometry'   => self.geometry,
      'properties' => {
        'geographic_item' => {
          'id' => self.id}
      }
    }
  end

  # def to_a
  #   see subclasses, perhaps not tested
  # end

  # '{"type":"Feature","geometry":{"type":"Point","coordinates":[2.5,4.0]},"properties":{"color":"red"}}'
  # '{"type":"Feature","geometry":{"type":"Polygon","coordinates":"[[[-125.29394388198853, 48.584480409793],[-67.11035013198853, 45.09937589848195],[-80.64550638198853, 25.01924647619111],[-117.55956888198853, 32.5591595028449],[-125.29394388198853, 48.584480409793]]]"},"properties":{}}'
  # @param [String] value
  def shape=(value)
    unless value.blank?
      geom      = RGeo::GeoJSON.decode(value, :json_parser => :json)
      this_type = JSON.parse(value)['geometry']['type']

      # TODO: @tuckerjd isn't this set automatically? Or perhaps the callback isn't hit in this approach?
      self.type = GeographicItem.eval_for_type(this_type) unless geom.nil?
      raise('GeographicItem.type not set.') if self.type.blank?

      object = Gis::FACTORY.parse_wkt(geom.geometry.to_s)
      write_attribute(this_type.underscore.to_sym, object)
      geom
    end
  end

  protected

  # @return [Symbol]
  #   returns the attribute (column name) containing data
  #   nearly all methods should use #geo_object_type, not geo_type
  def geo_type
    DATA_TYPES.each { |item|
      return item if self.send(item)
    }
    nil
  end

  def set_type_if_geography_present
    if self.type.blank?
      column    = geo_type
      self.type = "GeographicItem::#{column.to_s.camelize}" if column
    end
  end

  # @return [Array] of a point
  def point_to_a(point)
    data = []
    data.push(point.x, point.y)
    data
  end

  # @return [Hash] of a point
  def point_to_hash(point)
    {points: [point_to_a(point)]}
  end


  # @return [Array] of points
  def multi_point_to_a(multi_point)
    data = []
    multi_point.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  # @return [Hash] of points
  def multi_point_to_hash(multi_point)
    # when we encounter a multi_point type, we only stick the points into the array, NOT the
    # it's identity as a group
    {points: self.multi_point_to_a(self.multi_point)}
  end


  # @return [Array] of points in the line
  def line_string_to_a(line_string)
    data = []
    line_string.points.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  # @return [Hash] of points in the line
  def line_string_to_hash(line_string)
    {lines: [line_string_to_a(line_string)]}
  end

  # @return [Array] of points in the polygon (exterior_ring ONLY)
  def polygon_to_a(polygon)
    # todo: handle other parts of the polygon; i.e., the interior_rings (if they exist)
    data = []
    polygon.exterior_ring.points.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  # @return [Hash] of points in the polygon (exterior_ring ONLY)
  def polygon_to_hash(polygon)
    {polygons: [polygon_to_a(polygon)]}
  end

  # @return [Array] of line_strings as arrays points
  def multi_line_string_to_a(multi_line_string)
    data = []
    multi_line_string.each { |line_string|
      line_data = []
      line_string.points.each { |point|
        line_data.push([point.x, point.y]) }
      data.push(line_data)
    }
    data
  end

  # @return [Hash] of line_strings as hashes points
  def multi_line_string_to_hash(multi_line_string)
    {lines: self.to_a}
  end

  # @return [Array] of arrays points in the polygons (exterior_ring ONLY)
  def multi_polygon_to_a(multi_polygon)
    data = []
    multi_polygon.each { |polygon|
      polygon_data = []
      polygon.exterior_ring.points.each { |point|
        polygon_data.push([point.x, point.y]) }
      data.push(polygon_data)
    }
    data
  end

  # @return [Hash] of hashes points in the polygons (exterior_ring ONLY)
  def multi_polygon_to_hash(multi_polygon)
    {polygons: self.to_a}
  end

  # TODO: refactor to subclasses or remove completely, likely not useful given geojson capabilities
  # TODO: deprecate fully in favour of providing ids
  # @return [Boolean]
  def self.check_geo_params(column_name, geographic_item)
    return true
    # (DATA_TYPES.include?(column_name.to_sym) && geographic_item.class.name == 'GeographicItem')
  end

  # validation

  # @return [Boolean] iff there is one and only one shape column set
  def some_data_is_provided
    data = []
    DATA_TYPES.each do |item|
      data.push(item) unless self.send(item).blank?
    end

    errors.add(:base, 'must contain at least one of [point, line_string, etc.].') if data.count == 0
    if data.length > 1
      data.each do |object|
        errors.add(object, 'Only one of [point, line_string, etc.] can be provided.')
      end
    end
    true
  end

end
