# Shared code for extending data classes that impact CachedMap
#
# Models that include this must contain `has_one :cached_map`.
#
module Shared::Maps

  extend ActiveSupport::Concern

  included do
    after_create :update_cached_map
    after_destroy :cleanup_cached_map

#   # @return [Hash]
#   def cached_map_source

#     case self.class.base_class.name
#     when 'AssertedDistribution'

#       {
#         objects: [otu]
#         geographic_item_id: Gogra
#     }
#       [ otu ]
#     when 'Georeference'
#       collection_objects.to_a
#     end

#   end

    def update_cached_map
      cm = cached_map

      if cm.nil?
        if a =  cached_map_attribute_stub
          cm ||= CachedMap.new(a)
        end
      end

      return true if cm.nil? # We can't use this to affect a map, for some reason.

      if cm.persisted?
        cm.increment!(:reference_count)
      else
        cm.reference_count = 1
        cm.save!
      end

      true
    end

    def cleanup_cached_map
      cm = cached_map
      if cached_map.reference_count == 1
        cm.destroy!
      else
        cached_map.decrement!(:reference_count)
      end
      true
    end

    # TODO: deprecated for CachedMap version?
    # TODO: We must find the finest/correct shape at this point,
    #  * NOT just the current geographic_item_id *
    #
    # @return [Hash, nil]
    def cached_map_attributes
      geographic_item_id = nil
      name_hierarchy = nil
      otu_id = nil

      cm = CachedMap.new

      case self.class.base_class.name
      when 'AssertedDistribution'
        d = geographic_area.default_geographic_item
        geographic_item_id = d.id
        name_hierarchy = d.geographic_name_hierarchy
        otu_id = self.otu_id
      when 'Georeference'
        geographic_item_id = geographic_item.id
        name_hierarchy = geographic_item.geographic_name_hierarchy
      end

      if otu_id && geographic_item_id
        return {
          geographic_item_id:,
          level0_geographic_name: name_hierarchy[:country],
          level1_geographic_name: name_hierarchy[:state],
          level2_geographic_name: name_hierarchy[:county]
        }
      else
        return nil
      end
    end

  end
end
