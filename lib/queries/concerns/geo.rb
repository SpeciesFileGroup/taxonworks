require_dependency Rails.root.to_s + '/lib/queries/geographic_item/filter.rb'

# Helpers for geo-related queries
#
# !! You must call set_geo_params in initialize()
#
module Queries::Concerns::Geo
  extend ActiveSupport::Concern

  included do
    # @param geo_shape_type [Array, String]
    # @return [Array]
    attr_accessor :geo_shape_type

    # @param geo_shape_id [Array, Integer, String]
    # @return [Array]
    attr_accessor :geo_shape_id

    # @return [Boolean, nil]
    # How to treat geo_shapes
    #     nil - non-spatial match by only those records matching the
    #       geo_shape_id and
    #       geo_shape_type exactly
    #     true - spatial match
    #     false - non-spatial match matching against geo_shape descendants
    attr_accessor :geo_mode

    def geo_shape_type
      [@geo_shape_type].flatten.compact
    end

    def geo_shape_id
      [@geo_shape_id].flatten.compact
    end
  end

  def set_geo_params(params)
    @geo_shape_type = params[:geo_shape_type]
    @geo_shape_id = integer_param(params, :geo_shape_id)
    @geo_mode = boolean_param(params, :geo_mode)
  end

  def param_shapes_by_type
    geographic_area_ids = []
    gazetteer_ids = []
    i = 0
    geo_shape_id.each do |id|
      if geo_shape_type[i] == 'GeographicArea'
        geographic_area_ids << id
      else
        gazetteer_ids << id
      end
      i += 1
    end

    [geographic_area_ids, gazetteer_ids]
  end

  # @return [Array] Lists of the shapes corresponding to the existing
  #   geo_shape_id, geo_shape_type, and geo_mode parameters, separated by
  #   shape type (GeographicArea and Gazetteer).
  #   For geo_mode ==
  #     nil ("Exact"), returns shapes of each geo_shape_id/type
  #     true ("Spatial") same as nil
  #     false ("Descendants") returns shapes of each geo_shape_id/type and each
  #       of its descendants - each Gazetteer is considered a descendant of
  #       itself
  def shapes_for_geo_mode
    geographic_area_ids, gazetteer_ids = param_shapes_by_type

    geographic_area_shapes = shapes_for_geo_mode_by_type(
        'GeographicArea', geographic_area_ids
      )
    gazetteer_shapes = shapes_for_geo_mode_by_type(
        'Gazetteer', gazetteer_ids
      )

    [geographic_area_shapes, gazetteer_shapes]
  end

  def shapes_for_geo_mode_by_type(shape_string, ids)
    shape = shape_string.constantize
    return shape.none if ids.empty?

    a = nil

    case geo_mode
    when nil # exact
      a = shape.where(id: ids)
    when true #spatial
      if shape_string == 'GeographicArea'
        # In spatial mode GAs must have shape.
        a = shape.joins(:geographic_items).where(id: ids)
      else
        a = shape.where(id: ids)
      end
    when false # descendants
      if shape_string == 'Gazetteer'
        # For Gazetteers, descendants is the same as exact
        a = shape.where(id: ids)
      else
        a = shape.descendants_of_any(ids)
      end
    end

    a
  end
end
