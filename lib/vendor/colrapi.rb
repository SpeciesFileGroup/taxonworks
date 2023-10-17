module TaxonWorks
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

end
