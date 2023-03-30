# A map with low-res (Natural Earth) polygons
# suited for web (or SVG print?) printing?
#  All Geographic Items are level 0 or 1 NE
class CachedMap::WebLevel1 < CachedMap

  SOURCE_GAZETEERS = %w{ne_states ne_countries}.freeze

# # TODO test
# # Updated in subclasses
# def geographic_item_id=(id)

#   # find the smallest state or country level entity that fits this
#   #   by name ?
#   #   by shape ?

#   write_attribute(geographic_item_id: translate_geographic_item_id(id, SOURCE_GAZETEERS ))
# end


end
