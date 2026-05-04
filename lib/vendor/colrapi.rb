module Vendor

  # A middle-layer wrapper between Colrapi and TaxonWorks
  module Colrapi

    DATASETS = {
      col: '3LR', # The Human edited compilation
      col_extended: '3LXR'  # Human plus algorithmic extensions
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

    # Searches the Catalogue of Life by name string.
    #
    # The Colrapi gem takes dataset_id as a positional first argument.
    # Response structure: { 'total' => Integer, 'result' => Array }
    # Each result entry is a flat nameusage hash with keys:
    #   'id', 'status', 'name' (hash with 'scientificName', 'rank', 'authorship', …),
    #   'label', 'labelHtml', 'parentId', etc.
    #
    # @param name_string [String]
    # @param dataset_id [String, nil] CoL dataset ID; falls back to the default hardwired ID when nil
    # @return [Hash] raw Colrapi nameusage response (keys 'total', 'result')
    def self.search(name_string, dataset_id: nil)
      target = dataset_id.presence || DATASETS[:col]
      ::Colrapi.nameusage(target, q: name_string, limit: 20)
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.search error: #{e.message}"
      { 'total' => 0, 'result' => [] }
    end

    # Searches CoL datasets by name string.
    #
    # Returns an array of dataset summaries, each containing at least 'id', 'title', and 'alias'.
    # Used by the preferences UI to let users pick a target dataset.
    #
    # @param q [String] dataset name search string
    # @param limit [Integer]
    # @return [Array<Hash>]
    def self.datasets(q:, limit: 20)
      result = ::Colrapi.dataset(q: q, limit: limit)
      (result['result'] || []).map do |d|
        { 'id' => d['key'].to_s, 'title' => d['title'], 'alias' => d['alias'] }
      end
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.datasets error: #{e.message}"
      []
    end

    # Returns the ancestor classification chain for a CoL taxon.
    #
    # Uses Colrapi.taxon with subresource: 'classification'.
    # Response is an Array of hashes with keys: 'id', 'name' (String, not hash),
    # 'authorship', 'rank', 'label', 'labelHtml'.
    #
    # Only valid for backbone datasets (DATASETS[:col], DATASETS[:col_extended]).
    # For external datasets use ancestors_via_parent_id instead.
    #
    # @param taxon_id [String] CoL taxon ID (e.g. '6MB3T')
    # @return [Array<Hash>]
    def self.ancestors(taxon_id)
      ::Colrapi.taxon(DATASETS[:col], taxon_id: taxon_id, subresource: 'classification')
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.ancestors error: #{e.message}"
      []
    end

    # Returns true when dataset_id refers to one of the CoL backbone datasets that
    # support the classification subresource for ancestor retrieval.
    # External/denormed datasets (e.g. Mammal Diversity Database, dataset 9802) do not
    # have this subresource and require iterative parentId traversal instead.
    #
    # @param dataset_id [String]
    # @return [Boolean]
    def self.col_backbone_dataset?(dataset_id)
      DATASETS.values.include?(dataset_id.to_s)
    end

    # Builds an ancestor chain for external/denormed datasets by following the parentId
    # field of successive taxon records.
    #
    # External datasets (like the Mammal Diversity Database) are ingested into ChecklistBank
    # without a pre-built classification subresource.  Instead, each nameusage record carries
    # a parentId pointing to the immediate parent within the same dataset.
    #
    # Returns entries in the same format as the classification subresource used by ancestors():
    #   { 'id', 'name' (String uninomial), 'rank', 'authorship', 'label', 'labelHtml' }
    # Order is proximal-first (immediate parent first) matching ancestors() behavior.
    # The starting taxon itself is NOT included; only its ancestors are.
    #
    # @param dataset_id [String] the external dataset to query
    # @param taxon_id [String] ID of the starting taxon
    # @param max_depth [Integer] circuit-breaker against malformed/cyclic data
    # @return [Array<Hash>]
    def self.ancestors_via_parent_id(dataset_id, taxon_id, max_depth: 20)
      chain   = []
      visited = Set.new

      initial = ::Colrapi.taxon(dataset_id, taxon_id: taxon_id)
      return chain if initial.blank?

      current_id = initial['parentId']

      max_depth.times do
        break if current_id.blank? || visited.include?(current_id)
        visited << current_id

        taxon = ::Colrapi.taxon(dataset_id, taxon_id: current_id)

        break if taxon.blank?

        chain << {
          'id'         => current_id,
          'name'       => uninomial_name(taxon['name']).to_s,
          'rank'       => taxon.dig('name', 'rank'),
          'authorship' => taxon.dig('name', 'authorship'),
          'label'      => taxon.fetch('label', '').to_s,
          'labelHtml'  => taxon.fetch('labelHtml', '').to_s
        }

        current_id = taxon['parentId']
      end

      # Return distal-first (kingdom before genus) to match the classification subresource
      # order returned by ancestors(), so build_extension can treat both paths uniformly.
      chain.reverse
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.ancestors_via_parent_id error: #{e.message}"
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
    # @param dataset_id [String, nil] the dataset that was searched; falls back to DATASETS[:col]
    # @return [Hash] extension hash with :col_key, :col_name, :col_status, :col_authorship,
    #   :col_year, :col_rank, :col_dataset_id, and :alignment (Array of ancestor hashes each including :col_id, :dataset_id)
    def self.build_extension(col_result, project_id, dataset_id: nil)
      col_key        = col_result['id']
      col_name       = uninomial_name(col_result['name'])
      col_status     = col_result['status']
      col_authorship = col_result.dig('name', 'authorship')
      col_year       = col_result.dig('name', 'combinationAuthorship', 'year') ||
                       col_result.dig('name', 'basionymOrCombinationAuthorship', 'year')
      col_rank       = col_result.dig('name', 'rank')&.downcase

      # CoL nomenclatural code: 'zoological', 'botanical', 'bacterial', 'viral'
      col_code       = col_result.dig('name', 'code')

      # Dataset used for the search (target row).
      col_dataset_id = dataset_id.presence || DATASETS[:col]

      # Backbone datasets (main CoL, extended CoL) expose a classification subresource.
      # External/denormed datasets must be traversed via iterative parentId lookups.
      # Ancestor records carry the dataset_id of whichever source they came from.
      #
      # For synonyms, CoL attaches the synonym under its accepted name in the tree, so
      # fetching classification via the synonym's ID returns the accepted name in the chain.
      # Use the accepted name's ID for the lookup instead, then strip the accepted name
      # itself out by ID (CoL's classification endpoint includes the queried taxon itself
      # as the most proximal entry).
      accepted_id         = col_status == 'synonym' ? col_result.dig('accepted', 'id').presence : nil
      ancestor_lookup_key = accepted_id || col_key

      ancestor_chain, ancestor_dataset_id =
        if ancestor_lookup_key.present?
          if col_backbone_dataset?(col_dataset_id)
            [ancestors(ancestor_lookup_key), DATASETS[:col]]
          else
            [ancestors_via_parent_id(col_dataset_id, ancestor_lookup_key), col_dataset_id]
          end
        else
          [[], col_dataset_id]
        end

      ancestor_chain = ancestor_chain.reject { |a| a['id'] == accepted_id } if accepted_id

      # For synonyms, also strip any ancestor at or below the synonym's own rank.
      # This arises when the accepted name is at a lower rank than the synonym (e.g. a
      # genus synonym whose accepted name is a subgenus): the accepted name's classification
      # chain includes same- or lower-ranked entries that are not valid parents of the synonym.
      if col_status == 'synonym' && col_rank.present?
        target_sort = col_rank_sort(col_rank, col_code)
        if target_sort
          ancestor_chain = ancestor_chain.reject { |a|
            anc_sort = col_rank_sort(a['rank']&.downcase, col_code)
            anc_sort && anc_sort >= target_sort
          }
        end
      end

      # Drop suprakingdom ranks (e.g. 'domain') that have no equivalent in TaxonWorks
      # nomenclatural codes.  Kingdom is the highest rank we include.
      # CoL classification returns proximal→distal (immediate parent first); reverse to kingdom-first.
      ancestor_chain = ancestor_chain.reject { |a| a['rank']&.downcase == 'domain' }.reverse

      alignment = ancestor_chain.map do |ancestor|
        rank     = ancestor['rank']&.downcase
        # In classification entries 'name' is a plain String (the uninomial name)
        anc_name = ancestor['name'].is_a?(String) ? ancestor['name'] : ancestor.dig('name', 'scientificName')
        anc_name = extract_subgenus_name(anc_name) if rank == 'subgenus'
        col_id   = ancestor['id']

        scope = ::TaxonName.where(cached: anc_name) # !!!
        scope = scope.where(project_id:) if project_id.present?
        tw_record = scope.first

        {
          rank:,
          col_name:        anc_name,
          col_id:,
          dataset_id:      ancestor_dataset_id,
          col_authorship:  ancestor['authorship'].presence,
          taxonworks_id:   tw_record&.id,
          taxonworks_name: tw_record&.cached,
          match:           tw_record ? 'exact' : 'none'
        }
      end

      { col_key:, col_name:, col_status:, col_authorship:, col_year:, col_rank:, col_code:, col_dataset_id:, alignment: }
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

    # Subgenus names in CoL classification arrive as "Genus (Subgenus)" combinations.
    # Extract just the subgenus epithet from inside the parentheses when present.
    def self.extract_subgenus_name(name)
      return name if name.nil?
      name[/\(([^)]+)\)/, 1] || name
    end

    # Maps a CoL rank name ('genus', 'family', …) and CoL nomenclatural code
    # ('zoological', 'botanical', 'bacterial', 'viral') to the TaxonWorks RANK_SORT
    # index. Higher index = more specific rank. Returns nil when unresolvable.
    def self.col_rank_sort(rank_name, col_code)
      return nil if rank_name.blank?
      lookup = case col_code
               when 'zoological' then ::ICZN_LOOKUP
               when 'botanical'  then ::ICN_LOOKUP
               when 'bacterial'  then ::ICNP_LOOKUP
               when 'viral'      then ::ICVCN_LOOKUP
               else ::ICZN_LOOKUP
               end
      rank_class = lookup[rank_name]
      rank_class ? ::RANK_SORT[rank_class] : nil
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
