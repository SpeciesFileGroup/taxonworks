module Gis::GeoJSON
# not tested

=begin
 { "type": "FeatureCollection",
    "features": [
      { "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
        "properties": {"prop0": "value0"}
        },
      { "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
            ]
          },
        "properties": {
          "prop0": "value0",
          "prop1": 0.0
          }
        },
      { "type": "Feature",
         "geometry": {
           "type": "Polygon",
           "coordinates": [
             [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
               [100.0, 1.0], [100.0, 0.0] ]
             ]
         },
         "properties": {
           "prop0": "value0",
           "prop1": {"this": "that"}
           }
         }
       ]
     }
=end

  # @param objects [Array feature_collections]
  # @return [JSON object]
  def self.aggregation(objects, properties = nil)
    count  = 0
    result = {
      'type'     => 'Aggregation',
      'features' => []
    }
    objects.each_with_index do |object, i|
      unless object.nil?
        if object.class.to_s == 'Hash'
          json = object.merge('id' => i + 1)
        else
          json = object.to_geo_json_feature.merge('id' => i + 1) # offset by one, since google getFeatureById(0) fails
        end
        result['features'].push(json)
        count += 1
      end
    end
    unless properties.nil?
      result['properties'] = {properties.to_s => count}
    end
    result
  end


  # @param objects [Array of instances that respond to .to_geo_json_feature]
  # @return [geo_JSON object]
  def self.feature_collection(objects, properties = nil)
    count  = 0
    result = {
      'type'     => 'FeatureCollection',
      'features' => []
    }
    objects.each_with_index do |object, i|
      unless object.nil?
        if object.class.to_s == 'Hash'
          json = object.merge('id' => i + 1)
        else
          json = object.to_geo_json_feature.merge('id' => i + 1) # offset by one, since google getFeatureById(0) fails
        end
        result['features'].push(json)
        count += 1
      end
    end
    unless properties.nil?
      result['properties'] = {properties => {'count' => count}}
    end
    result
  end

  # @param [Object] object
  # @return [Hash]
  def self.feature(object)
    result = {
      'type'     => 'FeatureCollection',
      'features' => []
    }
    result['features'].push(object.to_geo_json_feature)
    result
  end

  # # @return [a Feature]
  # def to_geo_json_using_entity_factory
  #   f                   = RGeo::GeoJSON::EntityFactory.new
  #   inserted_attributes = {foo: "bar"} # some of self.attributes, but not all
  #   f.feature(self.geo_object, self.id, inserted_attributes)
  # end

end
