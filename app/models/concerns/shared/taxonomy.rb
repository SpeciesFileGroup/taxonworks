module Shared::Taxonomy
  extend ActiveSupport::Concern

  included do

    # @return [Hash]
    # {
    #     "nomenclatural rank" => "Root",
    #                  "order" => "Lepidoptera",
    #            "superfamily" => "Alucitoidea",
    #                 "family" => "Alucitidae",
    #                  "genus" => [
    #         [0] nil,
    #         [1] "Alucita"
    #     ],
    #                "species" => [
    #         [0] nil,
    #         [1] "acalles"
    #     ]
    # }
    #
    # !! Calling taxonom.keys gives ranks back from root to target.
    # !! Note Root is included, this may be deprecated ultimate
    # !!  as it is rarely used
    #
    # Currently based on full_name_hash format
    #
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

    # @return [Array]
    #   all ancestral names as string excepting self
    #   !! includes 'Root'
    def ancestry
      t = taxonomy.values.collect{|n| [n].flatten.compact.join(' ')}
      t.pop
      t
    end

    protected

    # !! @return Taxonomy
    # !! Always return a valid taxon name
    # TODO: analyze and optimize for n+1
    def set_taxonomy
      c = case self.class.base_class.name
          when 'CollectionObject', 'FieldOccurrence'
            a = target_taxon_name # current_valid_taxon_name # !! See DwcExtensions, probably better placed here

            # If we have no name, see if there is a Type reference and use it as proxy
            # !! Careful/TODO this is an arbitrary choice, technically can be only one primary, but not restricted in DB yet
            a ||= type_materials.primary.first&.protonym
          when 'Otu'
            if taxon_name 
              if taxon_name.cached_is_valid
                taxon_name
              else
                taxon_name.valid_taxon_name
              end
            end
            
          when 'AssertedDistribution'

            # TODO: this is faster, but needs spec confirmation
            # Benchmark.measure { 2000.times do;  AssertedDistribution.find_by_id(ids.sample).taxonomy; end;  }
            #
            # TaxonName.joins('JOIN taxon_names tn on tn.id = taxon_names.cached_valid_taxon_name_id')
            #   .joins('JOIN otus o on o.taxon_name_id = tn.id')
            #   .where(o: { id: otu_id })
            #   .first

            otu.taxon_name&.valid_taxon_name

          when 'TaxonName' # not used (probably has to be subclassed)
            self
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
