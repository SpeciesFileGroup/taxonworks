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

# @param objects [Array of instances that respond to .to_geo_json_1]
def self.feature_collection(objects)
  result = {
      'type'       => 'FeatureCollection',
      'features'   => []
  }
  objects.each_with_index do |o, i|
    json = o.to_geo_json_feature.merge('id' => i)
    result['features'].push(json)
  end
  result
end

# # @return [a Feature]
# def to_geo_json_using_entity_factory
#   f                   = RGeo::GeoJSON::EntityFactory.new
#   inserted_attributes = {foo: "bar"} # some of self.attributes, but not all
#   f.feature(self.geo_object, self.id, inserted_attributes)
# end

end
