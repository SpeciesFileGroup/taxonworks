# A GeographicArea is a gazeteer entry for some political subdivision. GeographicAreas are presently
# limited to second level subdivisions (e.g. counties in the United States) or higher (i.e. state/country)
# * "Levels" are non-normalized values for convenience.
#
# There are multiple hierarchies stored in GeographicArea (e.g. TDWG, GADM2).  Only when those
# name "lineages" completely match (via identical string) are they merged.
#
# @!attribute name
#   @return [String]
#   The name of the geographic area
#
# @!attribute level0_id
#   @return [Integer]
#   The id of the GeographicArea *country* that this geographic area belongs to, self.id if self is a country
#
# @!attribute level1_id
#   @return [Integer]
#   The id of the first level subdivision (starting from country) that this geographic area belongs to, self if self is a first level subdivision
#
# @!attribute level2_id
#   @return [Integer]
#   The id of the second level subdivision (starting from country) that this geographic area belongs to, self if self is a second level subdivision
#
# @!attribute parent_id
#   @return [Integer]
#   The id of the parent of this geographic area, will never be self, may be null (for Earth). Generally, sovereign countries have 'Earth' as parent.
#
# @!attribute geographic_area_type_id
#   @return [Integer]
#   The id of the type of this geographic area, index of geographic_area_types
#
# @!attribute iso_3166_a2
#   @return [String]
#   Two alpha-character identification of country.
#
# @!attribute iso_3166_a3
#   @return [String]
#   Three alpha-character identification of country.
#
# @!attribute tdwgID
#   @return [String]
#   If derived from the TDWG hierarchy the tdwgID.  Should be accessed through self#tdwg_ids, not directly.
#
# @!attribute data_origin
#   @return [String]
#   Text describing the source of the data used for creation (TDWG, GADM, NaturalEarth, etc.).
#
class GeographicArea < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData
  include Shared::IsApplicationData
  include Shared::AlternateValues
  include Shared::Identifiers

  include GeographicArea::DwcSerialization

  ALTERNATE_VALUES_FOR = [:name].freeze

  # @return class
  #   this method calls Module#module_parent
  # TODO: This method can be placed elsewhere inside this class (or even removed if not used)
  #       when https://github.com/ClosureTree/closure_tree/issues/346 is fixed.
  def self.parent
    self.module_parent
  end

  has_closure_tree

  # !! If this table changes we need to update this
  CACHED_GEOGRAPHIC_AREA_TYPES = {
    2 => 'Unknown',
    3 => 'Country',
    15 => 'Parish',
    18 => 'Province',
    33 => 'County',
    63 => 'State'
  }.freeze

  before_destroy :check_for_children

  belongs_to :geographic_area_type, inverse_of: :geographic_areas
  belongs_to :level0, class_name: 'GeographicArea'
  belongs_to :level1, class_name: 'GeographicArea'
  belongs_to :level2, class_name: 'GeographicArea'

  has_many :asserted_distributions, as: :asserted_distribution_shape, inverse_of: :asserted_distribution_shape
  has_many :collecting_events, inverse_of: :geographic_area
  has_many :common_names, inverse_of: :geographic_area
  has_many :geographic_areas_geographic_items, -> { ordered_by_data_origin }, dependent: :destroy, inverse_of: :geographic_area
  has_many :geographic_items, through: :geographic_areas_geographic_items

  accepts_nested_attributes_for :geographic_areas_geographic_items

  validates :geographic_area_type, presence: true
  validates :geographic_area_type_id, presence: true

  validates :parent, presence: true, unless: -> { self.name == 'Earth' } # || ENV['NO_GEO_VALID']}
  validates :level0, presence: true, allow_nil: true, unless: -> { self.name == 'Earth' }
  validates :level1, presence: true, allow_nil: true
  validates :level2, presence: true, allow_nil: true
  validates :name, presence: true, length: {minimum: 1}
  validates :data_origin, presence: true

  # @param geographic_area [Array, GeographicArea]
  #    all descendants of one or more GeographicAreas, *not* including geogrpahic_area
  scope :descendants_of, -> (geographic_area) { with_ancestor(geographic_area) }
  scope :ancestors_of, -> (geographic_area) { joins(:descendant_hierarchies).order('geographic_area_hierarchies.generations DESC').where(geographic_area_hierarchies: {descendant_id: geographic_area.id}).where('geographic_area_hierarchies.ancestor_id != ?', geographic_area.id) }

  scope :self_and_ancestors_of, -> (geographic_area) {
    joins(:descendant_hierarchies)
      .where(geographic_area_hierarchies: {descendant_id: geographic_area.id})
  }

  # HashAggregate  (cost=24274.42..24274.79 rows=37 width=77)
  # this is subtly different, it includes self in present form
  # scope :ancestors_and_descendants_of, -> (geographic_area) {
  #   joins('LEFT OUTER JOIN geographic_area_hierarchies a ON geographic_areas.id = a.descendant_id '  \
  #     'LEFT JOIN geographic_area_hierarchies b ON geographic_areas.id = b.ancestor_id')
  #     .where("(a.ancestor_id = ?) OR (b.descendant_id = ?)", geographic_area.id, geographic_area.id)
  #     .uniq
  # }

  #  HashAggregate  (cost=100.89..100.97 rows=8 width=77)
  scope :ancestors_and_descendants_of, -> (geographic_area) do
    scoping do
      a = GeographicArea.self_and_ancestors_of(geographic_area)
      b = GeographicArea.descendants_of(geographic_area)
      GeographicArea.from("((#{a.to_sql}) UNION (#{b.to_sql})) as geographic_areas")
    end
  end

  scope :with_name_like, lambda { |string|
    where(['name like ?', "#{string}%"])
  }

  # @param  [Array] of names of self and parent
  # @return [Scope]
  #  Matches GeographicAreas that have name and parent name.
  #  Call via find_by_self_and_parents(%w{Champaign Illinois}).
  scope :with_name_and_parent_name, lambda { |names|
    if names[1].nil?
      where(name: names[0])
    else
      joins('join geographic_areas ga on ga.id = geographic_areas.parent_id')
        .where(name: names[0]).where(['ga.name = ?', names[1]])
    end
  }

  # @param  [Array] names of self and parents
  # @return [Scope] GeographicAreas which have the names of self and parents
  # TODO: Test, or extend a general method
  # Matches GeographicAreas that match name, parent name, parent.parent name.
  # Call via find_by_self_and_parents(%w{Champaign Illinois United\ States}).
  scope :with_name_and_parent_names, lambda { |names|
    if names[2].nil?
      with_name_and_parent_name(names.compact)
    else
      joins('join geographic_areas ga on ga.id = geographic_areas.parent_id')
        .joins('join geographic_areas gb on gb.id = ga.parent_id')
        .where(name: names[0])
        .where(['ga.name = ?', names[1]])
        .where(['gb.name = ?', names[2]])
    end
  }

  scope :with_data_origin, -> (data_origin) {
    if data_origin.present?
      if data_origin == 'tdwg'
        where('geographic_areas.data_origin LIKE ?' , 'tdwg_%')
          .order(data_origin: :desc)
      elsif data_origin == 'ne'
        where('geographic_areas.data_origin LIKE ?', 'ne_%')
          .order(data_origin: :desc)
      else
        where(data_origin:)
      end
    end
  }

  scope :has_shape, -> (has_shape = true) {
    if has_shape
      joins(:geographic_areas_geographic_items)
    else
      left_joins(:geographic_areas_geographic_items)
      .where(geographic_areas_geographic_items: {id: nil})
    end
  }

  scope :ordered_by_area, -> (direction = :ASC) { joins(:geographic_items).order("geographic_items.cached_total_area #{direction || 'ASC'}") }

  # Based strictly on the original data recording a level ID,
  # this is *inferrence* and it will fail with some data.
  def self.inferred_as_country
    where('geographic_areas.level0_id = geographic_areas.id')
  end

  def self.inferred_as_state
    where('geographic_areas.level1_id = geographic_areas.id')
  end

  def self.inferred_as_county
    where('geographic_areas.level2_id = geographic_areas.id')
  end

  # Same results as descendant_of but starts with Array of IDs
  def self.descendants_of_any(ids = [])
    ids = [ids].flatten.compact.uniq
    return nil if ids.empty?

    descendants_subquery = GeographicAreaHierarchy.where(
      GeographicAreaHierarchy.arel_table[:descendant_id].eq(GeographicArea.arel_table[:id]).and(
        GeographicAreaHierarchy.arel_table[:ancestor_id].in(ids))
    )

    #unless descendants_max_depth.nil? || descendants_max_depth.to_i < 0
    #  descendants_subquery = descendants_subquery.where(GeographicAreaHierarchy.arel_table[:generations].lteq(descendants_max_depth.to_i))
    #end

    GeographicArea.where(descendants_subquery.arel.exists)
  end

  # @param array [Array] of strings of names for areas
  # @return [Scope] of GeographicAreas which match name and parent.name.
  # Route out to a scope given the length of the
  # search array.  Could be abstracted to
  # build nesting on the fly if we actually
  # needed more than three nesting levels.
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

  # @return [Scope] GeographicAreas which are countries.
  def self.countries
    includes(:geographic_area_type).where(geographic_area_types: {name: 'Country'})
  end

  # @param [GeographicArea]
  # @return [Scope, nil] of geographic_areas
  def self.is_contained_by(geographic_area)
    pieces = nil
    if geographic_area.geographic_items.any?
      pieces = GeographicItem.st_covered_by('any_poly',
        geographic_area.default_geographic_item)
      others = []
      pieces.each { |other|
        others.push(other.geographic_areas.to_a)
      }
      pieces = GeographicArea.where('id in (?)', others.flatten.map(&:id).uniq)
    end
    pieces
  end

  # @param [GeographicArea]
  # @return [Scope] geographic_areas which are 'children' of the supplied geographic_area.
  def self.are_contained_in(geographic_area)
    pieces = nil
    if geographic_area.geographic_items.any?
      pieces = GeographicItem.st_covers('any_poly',
        geographic_area.default_geographic_item)
      others = []
      pieces.each { |other|
        others.push(other.geographic_areas.to_a)
      }
      pieces = GeographicArea.where('id in (?)', others.flatten.map(&:id).uniq)
    end
    pieces
  end

  # @param latitude [Double] Decimal degrees
  # @param longitude [Double] Decimal degrees
  # @return [Scope] all areas which contain the point specified.
  def self.find_by_lat_long(latitude = 0.0, longitude = 0.0)
    point = ActiveRecord::Base.send(:sanitize_sql_array, ['POINT(:long :lat)', long: longitude, lat: latitude])

    ::GeographicArea.joins(:geographic_items)
      .where(
        ::GeographicItem.st_covers_sql(
          ::GeographicItem.geography_as_geometry,
          ::GeographicItem.st_geom_from_text_sql(point)
        )
      )
  end

  # @return [Scope]
  #   the finest geographic area in by latitude or longitude, sorted by area, only
  #   areas with shapes (geographic items) are matched
  def self.find_smallest_by_lat_long(latitude = 0.0, longitude = 0.0)
    ::GeographicArea
      .joins(:geographic_items)
      .merge(GeographicArea.find_by_lat_long(latitude, longitude))
      .select('geographic_areas.*, ST_Area(geography::geometry) AS sqft')
      .order('sqft')
      .distinct
  end

  # @return [Scope] of areas which have at least one shape
  # def self.have_shape?
  #  joins(:geographic_areas_geographic_items)
  # end

  def is_tdwg?
    data_origin =~ /tdwg/
  end

  # @return [Hash]
  #   A key/value pair that classify this GeographicArea
  #   into  a country, state, our county
  #   !! This is an estimation, although likely highly accurate.  It uses assumptions about how data are stored in GeographicAreas
  #   to derive additional data, particularly for State
  def categorize
    s = name
    if m = ::Utilities::Geo::DICTIONARY[s]
      s = m
    end

    # TODO: Wrap this a pre-loading constant. This makes specs very fragile.

    unless Rails.env.test?
      n = CACHED_GEOGRAPHIC_AREA_TYPES[geographic_area_type_id]
    end

    n ||= GeographicAreaType.where(id: geographic_area_type_id).limit(1).pick(:name)

    return {country: s} if GeographicAreaType::COUNTRY_LEVEL_TYPES.include?(n) || (id == level0_id) || (parent&.name == 'Earth' && !is_tdwg?)
    return {state: s} if GeographicAreaType::STATE_LEVEL_TYPES.include?(n) || (data_origin == 'ne_states') || (id == level1_id) || (!parent.nil? && (parent&.id == parent&.level0_id)) || ((parent&.parent&.name == 'Earth') && !is_tdwg?)
    return {county: s} if GeographicAreaType::COUNTY_LEVEL_TYPES.include?(n)

    return categorize_tdwg if is_tdwg?
    {}
  end

  # Hack. If TDWG Gazetteer data are eliminated this needs to be removed.
  #
  # TODO:
  #   * This seems very wrong in many was, TDWG does not have levels corresponding to countries in any place
  #
  def categorize_tdwg

    g = GeographicArea
      .where(name:)
      .where.not(geographic_area_type: [109, 110, 111,112])

    if g.any?
      return g.first.categorize
    end

    # !! Do not use ::Utilities::Geo::DICTIONARY here, this is particular to TDWG's names

    # TODO: more manual checks can be added here intermediate areas like "Western Canada"
    # Many other countries are a mess here.
    # TODO: -  Nothing about TDWG follows a hierarchy of level 0,1,2 == country, state, county style paradigm
    #       -  Could build some controlled vocabulary that translates values
    return {country: 'United States'} if name =~ /U\.S\.A/
    return {country: 'Canada'} if name =~ /Canada/
    return {country: 'Chile'} if name =~ /Chile.Central/
    return {country: name} if %w{Brazil New\ Zealand Mexico Brazil China Australia}.include?(name)

    {}
  end

  # @return [Hash]
  #   use the parent/child relationships of the this GeographicArea to return a country/state/county categorization
  #   {
  #     state: '',
  #     country: '',
  #     county: ''
  #   }
  def geographic_name_classification
    v = {}
    self_and_ancestors.each do |a|
      v.merge!(a.categorize)
    end
    v
  end

  # @return [Scope] all known level 1 children, generally state or province level.
  def children_at_level1
    GeographicArea.descendants_of(self).where('level1_id IS NOT NULL AND level2_id IS NULL')
  end

  # @return [Scope] all known level 2 children, generally county or prefecture level.
  def children_at_level2
    GeographicArea.descendants_of(self).where('level2_id IS NOT NULL')
  end

  # @param [String] geographic_area_type name of geographic_area_type (e.g., 'Country', 'State', 'City')
  # @return [Scope] descendants of this instance which have specific types, such as counties of a state.
  def descendants_of_geographic_area_type(geographic_area_type)
    GeographicArea.descendants_of(self).includes([:geographic_area_type])
      .where(geographic_area_types: {name: geographic_area_type})
  end

  # @param [Array] geographic_area_type_names names
  # @return [Scope] descendants of this instance which have specific types, such as cities and counties of a province.
  def descendants_of_geographic_area_types(geographic_area_type_names)
    GeographicArea.descendants_of(self).includes([:geographic_area_type])
      .where(geographic_area_types: {name: geographic_area_type_names})
  end

  # @return [Hash] keys point to each of the four level components of the ID.  Matches values in original data.
  def tdwg_ids
    {
      lvl1: tdwgID.slice(0),
      lvl2: tdwgID.slice(0, 2),
      lvl3: tdwgID.slice(2, 3),
      lvl4: tdwgID.slice(2, 6)
    }
  end

  # @return [String, nil] 1, 2, 3, 4 iff is TDWG data source
  def tdwg_level
    return nil unless data_origin =~ /TDWG/
    data_origin[-1]
  end

  # @return [Boolean]
  def has_shape?
    geographic_areas_geographic_items.any?
  end

  # @return [RGeo object] of the default GeographicItem
  def geo_object
    default_geographic_item&.geo_object
  end

  alias shape geo_object

  # @return [GeographicItem, nil]
  #   a "preferred" geographic item for this geographic area, where preference
  #     is based on an ordering of source gazeteers, the order being
  #   1) Natural Earth Countries
  #   2) Natural Earth States
  #   3) GADM
  #   4) everything else (at present, TDWG)
  def default_geographic_item
    default_geographic_area_geographic_item&.geographic_item
  end

  def default_geographic_item_id
    GeographicAreasGeographicItem.where(geographic_area_id: self.id).default_geographic_item_data.pluck(:geographic_item_id).first
  end

  # @return [GeographicAreasGeographicItem, nil]
  def default_geographic_area_geographic_item
    GeographicAreasGeographicItem.where(geographic_area_id: id).default_geographic_item_data.first
  end

  # rubocop:disable Style/StringHashKeys
  # @return [Hash] of the pieces of a GeoJSON 'Feature'
  def to_geo_json_feature
    to_simple_json_feature.merge(
      'properties' => {
        # cf. Gazetteer
        'shape' => {
          'type' => 'GeographicArea',
          'id' => id,
          'tag' => name
        }
      }
    )
  end

  # TODO: parametrize to include gazeteer
  #   i.e. geographic_areas_geogrpahic_items.where( gaz = 'some string')
  def to_simple_json_feature
    result = {
      'type' => 'Feature',
      'properties' => {}
    }
    area = geographic_items.order(:id) # Not prioritized!?

    result['geometry'] = area.first.to_geo_json unless area.empty?
    result
  end

  # Find a centroid by scaling this object tree up to the first antecedent which provides a geographic_item, and
  # provide a point on which to focus the map.  Return 'nil' if there are no GIs in the chain.
  # @return [GeographicItem] a point.
  def geographic_area_map_focus
    item = nil
    if geographic_items.count == 0
      # this nil signals the top of the stack: Everything terminates at 'Earth'
      item = parent.geographic_area_map_focus unless parent.nil?
    else
      item = GeographicItem.new(geography: geographic_items.first.st_centroid)
    end
    item
  end

  # @return [Hash]
  #   this instance's attributes applicable to GeoLocate
  def geolocate_attributes
    h = name_hash

    if item = geographic_area_map_focus # rubocop:disable Lint/AssignmentInCondition
      h['Longitude'] = item.geography.x
      h['Latitude']  = item.geography.y
    end

    h
  end

  # @return [Hash]
  def name_hash
    return {
      'country' => level0&.name,
      'state'   => level1&.name,
      'county'  => level2&.name
    }
  end

  def geolocate_ui_params
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_hash
  end

  # "http://www.geo-locate.org/web/webgeoreflight.aspx?country=United States of
  # America&state=Illinois&locality=Champaign&
  # points=40.091622|-88.241179|Champaign|low|7000&georef=run|false|false|true|true|false|false|false|0&gc=Tester"
  # @return [String]
  def geolocate_ui_params_string
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_string
  end

  # @return [Hash]
  #   query_line => [Array of GeographicArea]
  # @params [text]
  #   one result set per line (\r\n)
  #   lines can have child:parent:parent name patterns
  def self.matching(text, has_shape = false, invert = false)
    if text.nil? || text.length == 0
      return Hash.new('No query provided!' => [])
    end

    text.gsub!(/\r\n/, "\n")

    result  = {}
    queries = text.split("\n")
    queries.each do |q|
      names = q.strip.split(':')
      names.reverse! if invert
      names.collect { |s| s.strip }
      r = GeographicArea.with_name_and_parent_names(names)
      r = r.joins(:geographic_items) if has_shape
      result[q] = r
    end
    result
  end
  # rubocop:enable Style/StringHashKeys

  # @param used_on [String] one of `CollectingEvent` (default) or `AssertedDistribution`
  # @return [Scope]
  #    the max 10 most recently used (1 week, could parameterize) geographic_areas, as used `use_on`
  def self.used_recently(user_id, project_id, used_on = 'CollectingEvent')

    case used_on
    when 'CollectingEvent'
      t = CollectingEvent.arel_table
      # i is a select manager
      i = t.project(t['geographic_area_id'], t['updated_at']).from(t)
        .where(t['updated_at'].gt(1.week.ago))
        .where(t['updated_by_id'].eq(user_id))
        .where(t['project_id'].eq(project_id))
        .order(t['updated_at'].desc)

      # z is a table alias
      z = i.as('recent_t')
      p = GeographicArea.arel_table
      GeographicArea.joins(
        Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['geographic_area_id'].eq(p['id'])))
      ).pluck(:geographic_area_id).uniq
    when 'AssertedDistribution'
      t = Citation.arel_table
      # i is a select manager
      i = t.project(t['citation_object_id'], t['citation_object_type'], t['created_at']).from(t)
        .where(t['created_at'].gt(1.week.ago))
        .where(t['created_by_id'].eq(user_id))
        .where(t['project_id'].eq(project_id))
        .order(t['created_at'].desc)

      # z is a table alias
      z = i.as('recent_t')
      p = AssertedDistribution.arel_table

      AssertedDistribution
        .joins(
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['citation_object_id'].eq(p['id']).and(z['citation_object_type'].eq('AssertedDistribution')))  )
        )
        .where(asserted_distribution_shape_type: 'GeographicArea')
        .pluck(:asserted_distribution_shape_id).uniq
    end
  end

  # @params target [String] one of `CollectingEvent` or `AssertedDistribution`
  # @return [Hash] geographic_areas optimized for user selection
  def self.select_optimized(user_id, project_id, target = 'CollectingEvent')
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: GeographicArea.pinned_by(user_id).where(pinboard_items: {project_id:}).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = GeographicArea.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id:}).to_a
    else
      case target
      when 'CollectingEvent'
        h[:recent] = GeographicArea.where('"geographic_areas"."id" IN (?)', r.first(10) ).order(:name).to_a
      when 'AssertedDistribution'
        h[:recent] = GeographicArea.where('"geographic_areas"."id" IN (?)', r.first(15) ).order(:name).to_a
      end
      h[:quick] = (GeographicArea.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id:}).to_a +
                   GeographicArea.where('"geographic_areas"."id" IN (?)', r.first(5) ).order(:name).to_a).uniq
    end

    h
  end

  protected

  before_destroy :check_for_children

  def check_for_children
    unless leaf?
      errors[:base] << 'has attached names, delete these first'
      return false
    end
  end

end
