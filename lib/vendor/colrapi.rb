module Vendor

  # A middle-layer wrapper between Colrapi and TaxonWorks
  module Colrapi

    DATASETS = {
      col: '3LR'
  }.freeze

    # @params taxonworks_object
    #   any object that responds_to `.taxonomy`
    #
    # @params colrapi_result
    #    a nameusage result
    #
    # @return [Array]
    #   with hashes {
    #    { rank: 'species'
    #      col: 'name',
    #      taxonworks: 'name'
    #      rank_origin: :col, :taxonworks, :both
    #    }
    #
    # 2 row alignment facilitator
    #
    def self.align_classification(taxonworks_object, colrapi_result)
      r = []
    end

    # @params taxonworks_object
    #   currently only an CollectionObject
    #
    # @return hash
    #     { taxonworks_name: name }
    #      col_results: [
    #          { usage: {
    #             name:
    #             status:
    # },
    #          accepted: {}
    #         }
    #        ]
    #      }
    #
    def self.name_status(taxonworks_object, colrapi_result)
      o = taxonworks_object

      r = {
          taxonworks_name: collection_object_scientific_name(o),
          col_usages: [],
          provisional_status: :accepted,
      }

      if colrapi_result.dig('total') == 0
        r[:provisional_status] = :undeterminable
        return r
      end

      colrapi_result['result'].each do |u|
        i = u['usage']

        d = {
          usage: {},
          accepted: {}
        }

        d[:usage][:name] = i.dig *%w{name scientificName}
        d[:usage][:status] = i['status']

        if i['accepted']
          d[:accepted][:name] = i.dig *%w{accepted name scientificName}
          d[:accepted][:status] = i.dig *%w{accepted status}
        end

        if d[:usage][:status] == 'synonym' && (d[:usage][:name] == r[:taxonworks_name])
          r[:provisional_status] = :synonym
        end

        r[:col_usages].push d
      end
      r
    end


    # Searches the Catalog of Life by name string.
    #
    # The Colrapi gem takes dataset_id as a positional first argument.
    # Response structure: { 'total' => Integer, 'result' => Array }
    # Each result entry is a flat nameusage hash with keys:
    #   'id', 'status', 'name' (hash with 'scientificName', 'rank', 'authorship', …),
    #   'label', 'labelHtml', 'parentId', etc.
    #
    # @param name_string [String]
    # @return [Hash] raw Colrapi nameusage response (keys 'total', 'result')
    def self.search(name_string)
      ::Colrapi.nameusage(DATASETS[:col], q: name_string, limit: 20)
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.search error: #{e.message}"
      { 'total' => 0, 'result' => [] }
    end

    # Returns the ancestor classification chain for a CoL taxon.
    #
    # Uses Colrapi.taxon with subresource: 'classification'.
    # Response is an Array of hashes with keys: 'id', 'name' (String, not hash),
    # 'authorship', 'rank', 'label', 'labelHtml'.
    #
    # @param taxon_id [String] CoL taxon ID (e.g. '6MB3T')
    # @return [Array<Hash>]
    def self.ancestors(taxon_id)
      ::Colrapi.taxon(DATASETS[:col], taxon_id: taxon_id, subresource: 'classification')
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.ancestors error: #{e.message}"
      []
    end

    # Builds an alignment hash comparing a CoL nameusage result against TaxonNames in the project.
    #
    # col_result is a flat nameusage hash as returned by search (no 'usage' wrapper):
    #   { 'id' => '6MB3T', 'status' => 'accepted',
    #     'name' => { 'scientificName' => 'Homo sapiens', 'rank' => 'species',
    #                 'authorship' => 'Linnaeus, 1758',
    #                 'combinationAuthorship' => { 'authors' => [...], 'year' => '1758' } },
    #     'label' => 'Homo sapiens Linnaeus, 1758', … }
    #
    # Classification entries from ancestors() have:
    #   { 'id' => '636X2', 'name' => 'Homo', 'rank' => 'genus', 'label' => 'Homo', … }
    # Note: in classification entries 'name' is a plain String, not a hash.
    #
    # @param col_result [Hash] a single entry from search['result']
    # @param project_id [Integer, nil]
    # @return [Hash] extension hash with :col_key, :col_name, :col_status, :col_authorship,
    #   :col_year, :col_rank, and :alignment (Array of ancestor hashes each including :col_id)
    def self.build_extension(col_result, project_id)
      col_key       = col_result['id']
      col_name      = uninomial_name(col_result['name'])
      col_status    = col_result['status']
      col_authorship = col_result.dig('name', 'authorship')
      col_year      = col_result.dig('name', 'combinationAuthorship', 'year') ||
                      col_result.dig('name', 'basionymOrCombinationAuthorship', 'year')
      col_rank      = col_result.dig('name', 'rank')&.downcase

      ancestor_chain = col_key.present? ? ancestors(col_key) : []

      alignment = ancestor_chain.map do |ancestor|
        rank     = ancestor['rank']&.downcase
        # In classification entries 'name' is a plain String (the uninomial name)
        anc_name = ancestor['name'].is_a?(String) ? ancestor['name'] : ancestor.dig('name', 'scientificName')
        col_id   = ancestor['id']

        scope = ::TaxonName.where(cached: anc_name)
        scope = scope.where(project_id:) if project_id.present?
        tw_record = scope.first

        {
          rank:,
          col_name:        anc_name,
          col_id:,
          col_authorship:  ancestor['authorship'].presence,
          taxonworks_id:   tw_record&.id,
          taxonworks_name: tw_record&.cached,
          match:           tw_record ? 'exact' : 'none'
        }
      end

      { col_key:, col_name:, col_status:, col_authorship:, col_year:, col_rank:, alignment: }
    end

    # Returns the single-word name component suitable for storing as a TaxonWorks Protonym name.
    # CoL's scientificName is the full combination (e.g. "Homo sapiens"), but TaxonWorks
    # Protonym requires just the uninomial or epithet.
    # Priority: specificEpithet (species) > infraspecificEpithet (infra) > uninomial (higher) > scientificName fallback.
    #
    # @param name_hash [Hash, nil] the 'name' sub-hash from a CoL nameusage result
    # @return [String, nil]
    def self.uninomial_name(name_hash)
      return nil if name_hash.nil?
      name_hash['infraspecificEpithet'].presence ||
        name_hash['specificEpithet'].presence ||
        name_hash['uninomial'].presence ||
        name_hash['scientificName']
    end

    # Extend to buffered with GNA in middle layer?
    # Text only, taxon name cached or OTU name for the
    # most recent determination
    def self.collection_object_scientific_name(collection_object)
      return nil if collection_object.nil?
      if a = collection_object.taxon_determinations.order(:position)&.first
        if a.otu.taxon_name
          a.otu.taxon_name.cached
        else
          a.otu.name
        end
      else
        nil
      end
    end
  end

end
