# require 'colrapi'

module Vendor

  # A middle-layer wrapper between Colrapi and TaxonWorks
  #
  # Usage
  #   a = Vendor::Colrapi::Alignment.new(name: 'Quercus', project_id: 1)
  #   ap a.stub_names
  module Colrapi

    DATASETS = {
      col: '3LR',
      colxr: '3LXR'
    }.freeze

    class Alignment

      # @return Array
      #   of classification vectors
      attr_accessor :nameusage_result

      attr_accessor :taxonworks_ancestors

      attr_accessor :col_ancestors

      attr_reader :project_id

      attr_reader :name

      # The one we will operate on
      attr_accessor :target_usage

      # ... name objects
      # id
      # name
      # rank

      # TODO: revisit tuning, especially exact
      # TYPE: PREFIX, WHOLE_WORDS, EXACT
      def initialize(name: nil, dataset_id: '3LXR', project_id: nil)
        @nameusage_result = ::Colrapi.nameusage_search(dataset_id:, q: name, limit: 100, sort_by: 'RELEVANCE', type: 'EXACT')
        @project_id = project_id
        @name = name
      end

      def target_usage
        @target_usage ||= if nameusage_result['total'] == 0
                            nil
                          else
                            nameusage_result.dig('result')&.first
                          end
        @target_usage
      end

      def response_classification
        return [] if nameusage_result['total'] == 0
        target_usage['classification']
      end

      def response_classification_names
        return [] if nameusage_result['total'] == 0
        response_classification.collect{|b| b['name']}
      end

      def taxonworks_ancestors
        @taxonworks_ancestors ||= ::Protonym
          .where(cached: response_classification_names, project_id:)
          .order_by_rank(RANKS)
      end

      def taxonworks_ancestor_names
        taxonworks_ancestors.map(&:cached)
      end

      def align
        a1, a2 = Utilities::Arrays.align(
          response_classification_names,
          taxonworks_ancestor_names
        )
        [a1, a2]
      end

      # TODO: homonomy is a problem, but hopefully rare

      # @return an array of names, existing, or ready to create
      def stub_names
        r,t = align
        o = []

        current_parent = Project.find(project_id).root_taxon_name

        r.each_with_index do |n, i|

          case n
          when nil
            z = taxonworks_ancestors.select{|a| a.cached == n}.first
            o.push(z)
            current_parent = z
          else
            if t.include?(n)
              y = taxonworks_ancestors.select{|a| a.cached == n}.first
              o.push(y)
              current_parent = y
            else
              b = response_classification.select{|c| c['name'] == n}.first

              x = n

              case b['rank']
              when 'species'
                x = specific_epithet(target_usage)
              when 'subspecies'
                x = infraspecific_epithet(target_usage)
              end

              a, y = if i + 1 == r.size
                       [author, year]
                     else
                       [nil, nil]
                     end

              p = Protonym.new(
                name: x,
                rank_class: Ranks.lookup(nomenclature_code, b['rank']).presence,
                parent: current_parent,
                verbatim_author: a,
                year_of_publication: y
              )

              o.push p
              current_parent = p
            end
          end
        end
        o
      end

      def autoselect_payload_json(kind: :default)
        r = []
        stub_names.each do |n|
          r.push({
            id: n.id,
            name: n.name,
            rank_class: n.rank_class,
            parent_id: n.parent_id,
            verbatim_author: n.verbatim_author,
            year_of_publication: n.year_of_publication,
            cached_html: n.cached_html,
            cached: n.cached,
          })
        end
        r
      end

      # minimial stub -
      # concept of root, and moving back from there
      # hard target (shared names)
      # intermediates
      #   allowed ranks, not
      # target

      def nomenclature_code
        return :iczn if response_classification_names.include?('Animalia')
        return :icn if response_classification_names.include?('Plantae') # untested
        # ... TODO
      end

      def exact_match?
        nameusage_result.dig('result')&.first.dig('usage', 'name', 'scientificName') == name
      end

      def author
        a = target_usage.dig('usage', 'name', 'combinationAuthorship', 'authors')
        unless a.blank?
          return a.to_sentence(last_word_connector: ' & ', two_words_connector: ' & ' )
        end
        nil
      end

      def rank(result)
        result.dig('usage', 'name', 'rank')
      end

      def year
        target_usage.dig('usage', 'name', 'combinationAuthorship', 'year')
      end

      def scientific_name(result)
        result.dig('usage', 'name', 'scientificName')
      end

      def specific_epithet(result)
        result.dig('usage', 'name', 'specificEpithet')
      end

      def infraspecific_epithet(result)
        result.dig('usage', 'name', 'infraspecificEpithet')
      end

    end # end Alignment class

    # @return ActiveRecord Relation
    def self.ancestors_from_name(name: nil, dataset_id: '3LXR', project_id: nil)
      return ::TaxonName.none if name.blank? || project_id.blank?

      r = ::Colrapi.nameusage_search(dataset_id:, q: name, limit: 100)

      # Ignoring rank for now, fairly safe
    end

    def self.taxonworks_root
      ::TaxonName.lowest_common_ancestor(

      )
    end

    def self.interect_ancestors(nameusage_result)

    end

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
