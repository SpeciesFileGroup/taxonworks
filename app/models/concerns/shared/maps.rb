# Shared code for extending data classes that impact CachedMap
#
#
#
module Shared::Maps

  extend ActiveSupport::Concern

  included do
    after_save :update_cached_map
    after_destroy :cleanup_cached_map

    def update_cached_map
      observation_objects.each do |o|
        update_single_matrix_row o
      end
    end

    def cleanup_cached_map
      return true if observation_objects.count == 0
      ObservationMatrixRow.where(observation_matrix:, observation_object: observation_objects).each do |mr|
        decrement_matrix_row_reference_count(mr)
      end
      true
    end

    def cached_map_geographic_stub
      case self.class.base_class.name
      when 'AssertedDistribution'
        return {
          geographic_item_id: geographic_area.preferred_geographic_item.id,
          level1: nil
        }
      when 'Georeference'
        return {
          geographic_item_id: geographic_item.id
        }.merge(geographic_item.geographic_name_hierarchy)
      end
    end


  end

end
