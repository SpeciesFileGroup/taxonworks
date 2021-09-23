module Shared::Taxonomy

  extend ActiveSupport::Concern

  included do
    attr_accessor :taxonomy

    # @params reset [Boolean]
    # @return [Hash]
    #
    # Using `.reload` will not reset taxonomy!
    def taxonomy(reset = false)
      if reset
        reload
        @taxonomy = set_taxonomy
      else
        @taxonomy ||= set_taxonomy
      end
    end

    protected

    def set_taxonomy
      c = case self.class.base_class.name
          when 'CollectionObject'
            a = current_taxon_name
            
            # If we have no name, see if there is a Type reference and use it as proxy
            # !! Careful/TODO this is an arbitrary choice, technically can be only one primary, but not restricted in DB yet
            a ||= type_designations.primary.first&.protonym
          when 'Otu'
            taxon_name.valid_taxon_name
          end
      if c
        @taxonomy = c.full_name_hash
        # Check for required 'Kingdom'
        if @taxonomy['kingdom'].blank?

          # Det is only to kingdom!
          if c.rank == 'kingdom'
            @taxonomy['kingdom'] = c.name
          else

            # Kindom is provided in ancestors
            if a = c.ancestor_at_rank(:kingdom)
              @taxonomy['kingdom'] = a.name
            else

              # TODO: re-add when dwc_fields merged
              # Very edge case for single kingom nomenclatures (almost none)
              # if c.rank_class::KINGDOM.size == 1
              #   @taxonomy['kingdom'] = c.rank_class::KINGDOM.first
              # end


            end
          end
        end
        @taxonomy
      else
        @taxonomy ||= {}
      end
    end
  end
end
