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


    # @param name_string [String]
    # @return [Hash] raw Colrapi nameusage response (keys 'total', 'result')
    def self.search(name_string)
      ::Colrapi.nameusage(dataset_key: DATASETS[:col], q: name_string, limit: 20)
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.search error: #{e.message}"
      { 'total' => 0, 'result' => [] }
    end

    # @param taxon_key [String] CoL taxon ID
    # @return [Array] ancestor classification records from Colrapi
    def self.ancestors(taxon_key)
      ::Colrapi.taxon_classification(dataset_key: DATASETS[:col], taxon_id: taxon_key)
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.ancestors error: #{e.message}"
      []
    end

    # Builds an alignment hash comparing a CoL result against TaxonNames in the project.
    #
    # @param col_result [Hash] a single result entry from Colrapi nameusage response
    # @param project_id [Integer, nil]
    # @return [Hash] extension hash with :col_key, :col_name, :col_status, :alignment
    def self.build_extension(col_result, project_id)
      col_key    = col_result.dig('usage', 'id') || col_result['id']
      col_name   = col_result.dig('usage', 'name', 'scientificName') ||
                   col_result.dig('name', 'scientificName') ||
                   col_result['scientificName']
      col_status = col_result.dig('usage', 'status') || col_result['status']

      ancestor_chain = col_key.present? ? ancestors(col_key) : []

      alignment = ancestor_chain.map do |ancestor|
        rank     = ancestor.dig('name', 'rank')&.downcase
        anc_name = ancestor.dig('name', 'scientificName')

        scope = ::TaxonName.where(cached: anc_name)
        scope = scope.where(project_id:) if project_id.present?
        tw_record = scope.first

        {
          rank:,
          col_name: anc_name,
          taxonworks_id: tw_record&.id,
          taxonworks_name: tw_record&.cached,
          match: tw_record ? 'exact' : 'none'
        }
      end

      { col_key:, col_name:, col_status:, alignment: }
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
