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

    def cached_map_status
      return {
         registered: cached_map_registered,
         cached_map_items_to_clean: cached_map_items_to_clean.count,
      }
    end

    def cached_map_registered
      @cached_map_registered ||= cached_map_register.present?
    end

    # Presently unused.
    # TODO: deprecate for total rebuild approach (likely)
    # @return Array
    #   of CachedMapItem
    def cached_map_items_to_clean
      maps = []

      Behavior::Maps::DEFAULT_CACHED_BUILD_TYPES.each do |map_type|
        if stubs = CachedMapItem.stubs(self, map_type)
          stubs[:geographic_item_id].each do |geographic_item_id|
          # name_hierarchy =
          #   GeographicItem.find(
          #     geographic_item_id
          #   ).quick_geographic_name_hierarchy

            stubs[:otu_id].each do |otu_id|
              maps +=
                CachedMapItem.where(
                  type: map_type,
                  otu_id:,
                  geographic_item_id:,
                  untranslated: stubs[:untranslated],
                  project_id: stubs[:origin_object].project_id,
                   #  level0_geographic_name: name_hierarchy[:country],
                   #  level1_geographic_name: name_hierarchy[:state],
                   #  level2_geographic_name: name_hierarchy[:county]
                ).all
            end
          end
        end
      end
      maps
    end

    private

    # Creates or increments a CachedMapItem and creates a CachedMapRegister for this object.
    # * !! Assumes this is the first time CachedMapItem is being indexed for this object.
    # * !! Does NOT check register.
    def create_cached_map_items(batch = false)
      Behavior::Maps::DEFAULT_CACHED_BUILD_TYPES.each do |map_type|
        stubs = CachedMapItem.stubs(self, map_type)

        # Georeferences with no CollectionObjects will hit here
        #  TODO: do we still register this?
        return true if stubs[:otu_id].empty?

        name_hierarchy = {}

        stubs[:geographic_item_id].each do |geographic_item_id|
          stubs[:otu_id].each do |otu_id|
            begin
              CachedMapItem.transaction do
                a = CachedMapItem.find_or_initialize_by(
                    type: map_type,
                    otu_id:,
                    geographic_item_id:,
                    project_id: stubs[:origin_object].project_id,
                  )

                if a.persisted?
                  a.increment!(:reference_count)
                else

                  # When running in batch mode we assume we will use the label rake task to update
                  # en-masse after processing.
                  unless batch
                    name_hierarchy[geographic_item_id] ||= CachedMapItem.cached_map_name_hierarchy(geographic_item_id)
                    a.level0_geographic_name = name_hierarchy[geographic_item_id][:country],
                    a.level1_geographic_name = name_hierarchy[geographic_item_id][:state],
                    a.level2_geographic_name = name_hierarchy[geographic_item_id][:county]
                  end

                  a.untranslated = stubs[:untranslated]

                  a.reference_count = 1
                  a.save!
                end

                # There is little or no point to logging translations
                # for Georeferences, i.e. it is overhead with no benefit.
                unless self.kind_of?(Georeference)
                  # !! If the cache gets out of sync this may not be cached!
                  CachedMapItemTranslation.find_or_create_by!(
                    cached_map_type: map_type,
                    geographic_item_id: stubs[:origin_geographic_item_id],
                    translated_geographic_item_id: geographic_item_id
                  )
                end

                CachedMapRegister.create!(
                  cached_map_register_object: self,
                  project_id:
                )
              end


            rescue ActiveRecord::RecordInvalid => e
              logger.debug e
              # logger.debug 'source: ' + ap(self.to_s)
              # logger.debug @cm&.errors&.full_messages
              # logger.debug @cmit&.errors&.full_messages
            rescue PG::UniqueViolation
              logger.debug 'pg unique violation'
              # TODO: disable
              # logger.debug ap(self)
            end
          end
        end
      end
      true
    end

    def cleanup_cached_map
      cached_map_items_to_clean.each do |m|
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
