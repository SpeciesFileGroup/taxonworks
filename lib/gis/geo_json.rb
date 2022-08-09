module Gis::GeoJSON
  # not tested

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

  # @return String, nil
  #   a GeoJSON string
  # The point is to not instantiate a whole AR object, but query
  # as directly as possible to get the GeoJSON string value.
  # It's unclear as to whether this saves that much time.
  def self.quick_geo_json_string(geographic_item_id)
    return nil if geographic_item_id.nil?

    query = "ST_AsGeoJSON(#{GeographicItem::GEOMETRY_SQL.to_sql}::geometry) geo_json_str"
    a = GeographicItem.where(id: geographic_item_id)
      .select(query)
      .limit(1)
    ::GeographicItem.connection.select_all(a.to_sql)
      .first['geo_json_str']
  end

  # @return [GeoJSON] content for geometry
  def self.quick_geo_json(geographic_item_id)
    JSON.parse(quick_geo_json_string(geographic_item_id))
  end

  # # @return [a Feature]
  # def to_geo_json_using_entity_factory
  #   f                   = RGeo::GeoJSON::EntityFactory.new
  #   inserted_attributes = {foo: "bar"} # some of self.attributes, but not all
  #   f.feature(self.geo_object, self.id, inserted_attributes)
  # end

end
