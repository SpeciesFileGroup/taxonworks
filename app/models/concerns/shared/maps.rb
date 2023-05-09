

## Shared code for extending models that impact CachedMap (e.g. AssertedDistribution, Georeference)
#
module Shared::Maps
  extend ActiveSupport::Concern

  included do

    attr_accessor :cached_map_registered

    after_save :cue_process_cached_maps

    after_destroy :cleanup_cached_map

    def cue_process_cached_maps
      delay.syncronize_cached_maps
    end

    def syncronize_cached_maps
      if cached_map_registered
        cleanup_cached_map # wipe on prior
        created_cached_map_items
      else
        create_cached_map_items
      end
    end

    has_one :cached_map_register, as: :cached_map_register_object, dependent: :delete

    def cached_map_registered
      @cached_map_registered ||= cached_map_register.present?
    end

    def maps_to_clean
      maps = []

      Behavior::Maps::DEFAULT_CACHED_BUILD_TYPES.each do |map_type|
        if stubs = CachedMapItem.stubs(self, map_type)
          stubs[:geographic_item_id].each do |geographic_item_id|
            name_hierarchy =
              GeographicItem.find(
                geographic_item_id
              ).quick_geographic_name_hierarchy

            stubs[:otu_id].each do |otu_id|
              maps +=
                CachedMapItem.where(
                  type: map_type,
                  otu_id:,
                  geographic_item_id:,
                  untranslated: stubs[:untranslatable],
                  project_id: stubs[:origin_object].project_id,
                  level0_geographic_name: name_hierarchy[:country],
                  level1_geographic_name: name_hierarchy[:state],
                  level2_geographic_name: name_hierarchy[:county]
                ).all
            end
          end
        end
      end
      maps
    end

    private

    #  def syncronize_cached_map_register
    #    return true if cached_map_registered

    #    a = CachedMapRegister.find_or_initialize_by(cached_map_register_object: self, project_id:)
    #    if a.persisted?
    #      a.touch
    #    else
    #      a.save!
    #    end
    #  end


    # !! Assumes this is the first time CachedMapItem is being
    # !! indexed for this object.
    #  Creates or increments a CachedMapItem and creates a CachedMapRegister for this object.
    def create_cached_map_items
      Behavior::Maps::DEFAULT_CACHED_BUILD_TYPES.each do |map_type|
        stubs = CachedMapItem.stubs(self, map_type)

        stubs[:geographic_item_id].each do |geographic_item_id|
          name_hierarchy = CachedMapItem.cached_map_name_hierarchy(geographic_item_id)
          stubs[:otu_id].each do |otu_id|
            begin
              CachedMapItem.transaction do
                a = CachedMapItem.find_or_initialize_by(
                    type: map_type,
                    otu_id:,
                    geographic_item_id:,
                    project_id: stubs[:origin_object].project_id,
                    # TODO: is_absent:  !!!
                    level0_geographic_name: name_hierarchy[:country],
                    level1_geographic_name: name_hierarchy[:state],
                    level2_geographic_name: name_hierarchy[:county]
                  )

                if a.persisted?
                  a.increment!(:reference_count)
                else
                  a.reference_count = 1
                  a.save!
                end

                # TODO: there is no or very little point in logging translation
                #   !! for Georeferences, all overhead for almost no benefit
                # We could call this if !a.persisted,
                # but there are sync issues potentially
                #
                # !! If the cache gets out of sync this may not be cached!
                CachedMapItemTranslation.find_or_create_by!(
                  cached_map_type: map_type,
                  geographic_item_id: stubs[:origin_geographic_item_id],
                  translated_geographic_item_id: geographic_item_id
                )

                CachedMapRegister.create!(
                  cached_map_register_object: self,
                  project_id:
                )
              end
            rescue ActiveRecord::RecordInvalid => e
              # TODO: disable
              logger.debug e
              logger.debug ap(self)
            rescue PG::UniqueViolation
              # TODO: disable
              puts 'pg unique violation'
              logger.debug ap(self)
            end
          end
        end
      end
      true
    end

    def cleanup_cached_map
      maps_to_clean.each do |m|
        if m.reference_count == 1
          m.delete
        else
          m.decrement!(:reference_count)
        end
      end
      true
    end
  end
end
