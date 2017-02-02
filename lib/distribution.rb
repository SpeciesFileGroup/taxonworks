# An array of OTU distributions
#
#
# 
#
class Distribution

  # A cache of the aggregate data to be parsed into json per OTU 
  # { 
  #    otu_id => [
  #      [ asserted_distribution, geographic_area, type ], 
  #      [ collecting_event, georeference, type ], 
  #      [ collecting_event, geographic_area, type ] 
  #    ] 
  # }
  attr_accessor :map_source_objects

  # A parameter that indicates which types of data should be extracted for the list of OTUs provided
  #  [ asserted_distribution, :collecting_event_geographic_area, :collecting_event_georeference ]
  attr_accessor :source_object_types

  # the list of OTUs to generate distributions for 
  attr_accessor :otus

  attr_accessor :preferred_georeference_only

  def initialize(
    source_object_types: [
      :asserted_distribution,
      :collecting_event_geographic_area,
      :collecting_event_georeference],
    otus: [],
    preferred_georeference_only: false # does nothing at present
  )
    @preferred_georeference_only = preferred_georeference_only
    @source_object_types         = source_object_types
    @otus                        = otus
  end

  def map_source_objects
    @map_source_objects ||= build_map_source_objects
  end

  def build_map_source_objects
    @map_source_objects = {} if @map_source_objects.nil?
    otus.each do |o|
      @map_source_objects[o.id] = []
      source_object_types.each do |t|
        insert_source_objects(o, t)
      end
    end
    @map_source_objects
  end

  def insert_source_objects(otu, type)
    records_with_data = self.send("get_data_for_#{type}s", otu) # all returned data must have geographic_item at this point
    records_with_data.each do |r|
      self.send("insert_for_#{type}", otu, r, type)
    end
  end

  # json insert necessary 
  def insert_for_asserted_distribution(otu, source, type)
    insert_source_object(otu, source, source.geographic_area, type)
  end

  def insert_for_collecting_event_geographic_area(otu, source, type)
    insert_source_object(otu, source, source.geographic_area, type)
  end

  def insert_for_collecting_event_georeference(otu, source, type)
    georeferences = (preferred_georeference_only ? [source.georeferences.first] : source.georeferences)
    georeferences.each do |g|
      insert_source_object(otu, source, g, type)
    end
  end

  def insert_source_object(otu, source, data, type)
    @map_source_objects[otu.id].push([source, data, type])
  end

  def geographic_item_for_collecting_event_geographic_area(collecting_event)
    collecting_event.geographic_area.geographic_items.first
  end

  def geographic_item_for_collecting_event_georeference(collecting_event)
    asserted_distribution.geographic_area.geographic_items.first
  end

  def get_data_for_asserted_distributions(otu)
    otu.asserted_distributions # .where(geographic_area has a shape clause)
  end

  # have a better has_many method for this I think
  def get_data_for_collecting_event_geographic_areas(otu)
    otu.collecting_events.joins(geographic_area: [:geographic_items])
  end

  def get_data_for_collecting_event_georeferences(otu)
    [otu]
  end


  def to_json
    result = {
      'otu_ids' => map_source_objects.keys
    }

    i = 1
    j = 0
    map_source_objects.keys.each do |otu_id|
      feature_collection = {
        'type'     => 'FeatureCollection',
        'features' => []
      }
      colors             = [
        ["black", 0x000000], ["blue", 0x000088], ["orange", 0xDD6600], ["green", 0x008800], ["red", 0x880000],
        ["purple", 0x880088], ["yellow", 0xAAAA55], ["brown", 0x664400], ["gray", 0x666666],
        ["white", 0xFFFFFF], ["shadow", 0x888888]]
      opacities          = {'asserted_distribution' => 0.66, 'collecting_event_georeference' => 0.44, 'collecting_event_geographic_area' => 0.22}
      map_source_objects[otu_id].each do |source, data, type|
        source_class = source.class.name
        route_base   = source.class.table_name

        color_index = (j + 1) % 8 # only 8 colors, excluding black and white (mousover color)
        color_name  = colors[color_index][0]
        color       = sprintf('#%06X', colors[color_index][1])

        json = data.to_simple_json_feature
        json['properties'].merge!(
          'id'          => i,
          'source'      => source_class,
          'source_type' => type.to_s,
          'metadata'    => {source_class => source.attributes},
          'api'         => {
            'concise_details'  => "/#{route_base}/#{data.id}/concise_details",
            'expanded_details' => "/#{route_base}/#{data.id}/expanded_details"
          },
          'colorName'   => color_name,
          'fillColor'   => color,
          'fillOpacity' => opacities[type.to_s]
        )

        send("#{type}_properties", json, source, data)

        feature_collection['features'].push(json)
        i = i + 1
      end
      j = j + 1
      result.merge!(otu_id => feature_collection)
    end
    result
  end

  def asserted_distribution_properties(json, asserted_distribution, data)
    json['properties'].merge!('label' => asserted_distribution.geographic_area.name)
    json['properties']['metadata'].merge!('GeographicArea' => asserted_distribution.geographic_area.attributes)
    json['properties']['metadata'].merge!('Source' => asserted_distribution.source.attributes)
  end

  def collecting_event_geographic_area_properties(json, collecting_event, data)
    json['properties'].merge!('label' => collecting_event.geographic_area.name)
    json['properties']['metadata'].merge!('GeographicArea' => collecting_event.geographic_area.attributes)
  end

  def collecting_event_georeference_properties(json, georeference, data)
    json['properties'].merge!('label' => "Collecting event #{data.id}.")
  end

end
