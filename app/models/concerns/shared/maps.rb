## Shared code for extending models that impact CachedMap creation (at present AssertedDistribution, Georeference).
#
# TODO:
# - callbacks in all potentially altering models, e.g.: 
#   * AssertedDistribution (geographic_area_id change, otu_id change)
#   * GeographicItem (shape change) ?! necessary or we destroy/update !?
#   * CollectionObject (collecting_event_id change)
#   * Georeference (geographic_item change, position_change, collecting_event_id change)
#   * OTU change (taxon_name_id change)
#   * TaxonDetermination (otu_id change, position change)
#   * GeographicArea - !?!@# (new/altered gazetters)
#
# - provide 2 shapes, absent/present when both there
# - resolve "untranslated" when rendering 
#
module Shared::Maps
  extend ActiveSupport::Concern

  included do
    attr_accessor :cached_map_registered

    has_one :cached_map_register, as: :cached_map_register_object, dependent: :delete

    after_create :initialize_cached_map_items
    before_destroy :remove_from_cached_map_items

    # after_update :syncronize_cached_map_items

    # !! This should only impacts the CachedMapItem layer. See CachedMapItem for
    # triggers that will propagate to CachedMap.
    # def syncronize_cached_map_items
      # delay.coordinate_cached_map_items
    # end

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
            stubs[:otu_id].each do |otu_id|
              maps +=
                CachedMapItem.where(
                  type: map_type,
                  otu_id:,
                  geographic_item_id:,
                  untranslated: stubs[:untranslated],
                  project_id: stubs[:origin_object].project_id,
                ).all
            end
          end
        end
      end
      maps
    end

    private

    def initialize_cached_map_items
      delay.create_cached_map_items, queue: 'cached_map'
    end

    def remove_from_cached_map_items
      delay.deduct_from_cached_map_items, queue: 'cached_map'
    end

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
            rescue PG::UniqueViolation
              logger.debug 'pg unique violation'
            end
          end
        end
      end
      true
    end

    def deduct_from_cached_map_items
      cached_map_items_to_clean.each do |cmi|
        if cmi.reference_count == 1
          cmi.delete
        else
          cmi.decrement!(:reference_count)
        end
      end
      true
    end

    # def coordinate_cached_map_items
    #   if cached_map_registered
    #     # Wipe existing reference
    #     cleanup_cached_map_items # wipe on prior
    #     create_cached_map_items
    #   else
    #     create_cached_map_items
    #   end
    #   true
    # end

  end
end
