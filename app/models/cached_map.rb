# Consider manual build triggers builds for some types

# * CONSIDER USING DELAYED JOBS FOR MAPPING!!

# TODO: this has to happen in all potentially altering models
#    TaxonDetermination (otu_id change)
#    Georeference (geographic_item change)
#    AssertedDistribution (geographic_area_id change, otu_id change)
#    GeographicItem (shape change) ?! necessary or we destroy/update !?
# after_update :check_for_cached_map_changes

# TODO: write (re-indexer) method

# Radial navigate from CollectingEvent to
#
# TODO:

# * TaxonDetermination position change
# * OTU change
# * AssertedDistribution change
# * Georefrence change
# * CollectingEvent change

# Validation of Gaz shape type from Subtypes
#
# By default us NE NE shapes as target OR
#
#  gadm
#  ne_countries
#  ne_states
#  tdwg_l1
#  tdwg_l2
#  tdwg_l3
#  tdwg_l4
#
#


# This is an abstract class.
#
# Summarize data from Georeferences and AssertedDistributions for mapping/visualization purposes.
# All data are `cached` sensu TaxonWorks, i.e. derived from underlying data elsewhere.  The intent is *not*
# to preserve the origin of the data, but rather provide a tool to summarize via a simple visualization (returning a DwC facilitates the former).
#
#
## @!attribute otu_id
#   @return [Otu#id],
#     the id of OTU, required
#
# @!attribute geographic_item_id
#   @return [GeographicItem#id],
#     the id of GeographicItem, required
#
# @!attribute type
#   @return [String]
#     Rails STI
#
# @!attribute reference_count
#   @return [Integer]
#      the number of Georeferences + AssertedDistributions that
#   reference this OTU/shape combination. . . . .
#
# @!attribute is_absent
#   @return [Boolean, nil]
#     if True then the corresponding AssertedDistributions have is_absent true
#
# @!attribute level0_geographic_name
#   @return [String, nil]
#      the level 0 name
#
# @!attribute level1_geographic_name
#   @return [String, nil]
#      the level 1 name
#
# @!attribute level2_geographic_name
#   @return [String, nil]
#      the level 2 name. !! Not presently used. !!
#
class CachedMap < ApplicationRecord

  include Housekeeping::Projects
  include Housekeeping::Timestamps

  include Shared::IsData

  belongs_to :otu
  belongs_to :geographic_item

=begin
  attr_accessor :source_object

  def source_object=(object)
    if a = stub(object)
      # TODO: write paradigm
      self.geographic_item_id = a[:geographic_item_id]
      self.level0_geographic_name = a[:level0_geographic_name]
      self.level1_geographic_name = a[:level1_geographic_name]
      self.level2_geographic_name = a[:level2_geographic_name]
    end
  end
=end

  validates_presence_of :otu, :geographic_item

  # Have to do more to return stuff here
  def self.translate_geographic_item_id(geographic_item_id, data_origin = [])
    return nil if data_origin.blank?

    base = ::GeographicAreasGeographicItem.where(geographic_item_id:, data_origin:)

    # Simplest is if the geographic_item_id is of the gazeteer type and shape matches
    return geographic_item_id if base.any?

    # GeographicItem is an alternate shape to a GeographicArea that *also* has a target gazeteer type
    if a = GeographicItem.find(geographic_item_id).geographic_areas.joins(:geographic_items).where(geographic_areas: {data_origin:}).order(cached_total_area: :ASC).first&.id
      return a
    end

    # Go spatial
    GeographicItem.joins(:geographic_areas_geographic_items)
      .where(::GeographicItem.within_radius_of_item_sql(geographic_item_id, 0.0))
      .where(geographic_areas_geographic_items: {data_origin:})
      .order('geographic_items.cached_total_area ASC').first&.id
  end

  # @return [Hash, nil]
  #  { cached_map: CachedMap.new(),
  #    objects: [],
  #    origin_object: object
  #  }
  #
  #  Need one new CachedMap per object
  #
  def self.stubs(source_object, cached_map_type)
    return nil unless source_object.persisted?
    o = source_object

    h = {
      origin_object: o,
      cached_map: CachedMap.new(type: cached_map_type),
      otu_id: []
    }

    geographic_item_id = nil
    name_hierarchy = nil
    otu_id = nil

    case o.class.base_class.name

    when 'AssertedDistribution'
      d = o.geographic_area.default_geographic_item
      geographic_item_id = d.id
      name_hierarchy = d.geographic_name_hierarchy
      otu_id = [o.otu_id]
    when 'Georeference'
      geographic_item_id = o.geographic_item.id
      name_hierarchy = o.geographic_item.geographic_name_hierarchy
      otu_id = [ o.otus.where(taxon_determinations: {position: 1}).pluck(:id) ]
    end

    geographic_item_id = translate_geographic_item_id(geographic_item_id, cached_map_type.safe_constantize::SOURCE_GAZETEERS )

    h[:cached_map].geographic_item_id = geographic_item_id
    h[:cached_map].level0_geographic_name = name_hierarchy[:country]
    h[:cached_map].level1_geographic_name = name_hierarchy[:state]
    h[:cached_map].level2_geographic_name = name_hierarchy[:county]

    h[:otu_id] = otu_id

    h
  end

 ## TODO test
 ## Updated in subclasses
 #def geographic_item_id=(id)
 #  write_attribute(geographic_item_id: id)
 #end

end
