module Vendor

  # A middle-layer wrapper between Colrapi and TaxonWorks
  module Colrapi

    DATASETS = {
      col: '3LR', # The Human edited compilation
      col_extended: '3LXR'  # Human plus algorithmic extensions
    }.freeze


    # CoL usage statuses under which a name is in use.
    COL_ACCEPTED_STATUSES = ['accepted', 'provisionally accepted'].freeze

    # What CoL says about the status of a name.
    #
    # CoL is searched with NameTranslation.search_term, and its usages are
    # compared to the name by NameTranslation key, not exact string - CoL
    # doesn't write a name the same way TaxonWorks does, or even consistently
    # (see NameTranslation). A usage whose key matches makes the name
    #   * :accepted - accepted, or a synonym of a name with the same key (e.g.
    #     an original combination CoL lists under its own species)
    #   * :synonym - a synonym of a different name, i.e. outdated
    #   * :ambiguous_synonym - an ambiguous synonym (several possible targets)
    # in that order of precedence. With no matching usage it's
    # :undeterminable.
    #
    # A TaxonName is looked up by one of its NameTranslation.forms: an
    # invalid Protonym by its published form (original combination), since
    # CoL lists synonyms as published while TaxonWorks moves a synonym under
    # its valid name's parent (project 13 sample, 2026-10: of 40 synonyms whose
    # two forms differ, CoL had the original combination for 38 and #cached
    # for 7, never #cached alone); anything else by its current form (a
    # Combination, which has none, by its published one). A published form is
    # searched at the rank it was published at.
    #
    # @param target [TaxonName, String, nil] the name to check: a TaxonName
    #   when there is one (searched at its own rank, or the rank its
    #   published form was published at), else a name string, searched as a
    #   species
    #   - for a CollectionObject see Tasks::CollectionObjects::
    #   OutdatedNamesHelper#outdated_names_target
    # @return [Hash]
    #   { taxonworks_name: String,
    #     col_usages: [ { usage: { name:, status: },
    #                     accepted: { name:, status: } } ],
    #     provisional_status: Symbol }
    def self.name_status(target)
      if target.is_a?(::Combination)
        # Only a published form, at the rank it was published at (its finest
        # element), which needn't be its protonym's rank now.
        name = NameTranslation.forms(target)[:published]
        rank = target.protonyms_by_rank.keys.last
      elsif target.is_a?(::TaxonName)
        forms = NameTranslation.forms(target)
        invalid_protonym =
          target.is_a?(::Protonym) && !target.cached_is_valid
        rank = ::RANKS_LOOKUP[target.rank_class.to_s]
        if invalid_protonym && forms[:published]
          # At the rank it was published at, e.g. a species published as a
          # variety, or a subgenus as a genus.
          name = forms[:published]
          rank = published_rank(target) || rank
        else
          name = forms[:current]
        end
      else
        name = target
        # TODO: try harder here.
        rank = 'species'
      end
      key = NameTranslation.name_key(name)

      results =
        if key.present?
          ::Colrapi.nameusage_search(
            q: NameTranslation.search_term(name),
            dataset_id: DATASETS[:col],
            rank:
          )['result']
        end

      statuses = []
      col_usages = (results || []).map do |result|
        usage = result['usage']
        statuses << usage_status(usage, key) if usage_key(usage) == key

        accepted = {}
        if usage['accepted']
          accepted = {
            name: usage.dig('accepted', 'name', 'scientificName'),
            status: usage.dig('accepted', 'status')
          }
        end

        {
          usage: {
            name: usage.dig('name', 'scientificName'),
            status: usage['status']
          },
          accepted:
        }
      end

      provisional_status =
        [:accepted, :synonym, :ambiguous_synonym]
          .find { |status| statuses.include?(status) } || :undeterminable

      { taxonworks_name: name, col_usages:, provisional_status: }
    end

    # @param protonym [Protonym]
    # @return [String, nil] the rank protonym was published at, the finest
    #   rank of its original combination; nil without one
    def self.published_rank(protonym)
      types = protonym.original_combination_relationships.pluck(:type)
      ::ORIGINAL_COMBINATION_RANKS
        .select { |_rank, type| types.include?(type) }
        .keys.last&.to_s
    end
    private_class_method :published_rank

    # @param usage [Hash] a nameusage_search usage
    # @return [String, nil] its comparison key
    def self.usage_key(usage)
      NameTranslation.col_name_key(
        usage.dig('name', 'scientificName'), usage.dig('name', 'rank')
      )
    end
    private_class_method :usage_key

    # @param usage [Hash] a nameusage_search usage whose key matches key
    # @param key [String] the TaxonWorks name's comparison key
    # @return [Symbol, nil] what the usage says about the name, see .name_status
    def self.usage_status(usage, key)
      case usage['status']
      when *COL_ACCEPTED_STATUSES
        :accepted
      when 'synonym'
        # A synonym of a name with the same key is the same name, so it isn't
        # outdated. CoL lists "Aphrophora ambigua" (the original combination,
        # no subgenus) as a synonym of accepted "Aphrophora (Aphrophora)
        # ambigua".
        accepted_key = NameTranslation.col_name_key(
          usage.dig('accepted', 'name', 'scientificName'),
          usage.dig('accepted', 'name', 'rank')
        )
        accepted_key == key ? :accepted : :synonym
      when 'ambiguous synonym'
        :ambiguous_synonym
      end
    end
    private_class_method :usage_status

    # Searches the Catalogue of Life by name string.
    #
    # The Colrapi gem takes dataset_id as a positional first argument.
    # Response structure: { 'total' => Integer, 'result' => Array }
    # Each result entry is the name usage itself (not wrapped in 'usage' as
    # nameusage_search entries are), with keys:
    #   'id', 'status', 'name' (hash with 'scientificName', 'rank', 'authorship', …),
    #   'label', 'labelHtml', 'parentId', etc.
    #
    # @param name_string [String]
    # @param dataset_id [String, nil] CoL dataset ID; falls back to the default
    #   hardwired ID when nil
    # @param limit [Integer] maximum number of results
    # @return [Hash] raw Colrapi nameusage response (keys 'total', 'result')
    def self.search(name_string, dataset_id: nil, limit: 20)
      target = dataset_id.presence || DATASETS[:col]
      ::Colrapi.nameusage(target, q: name_string, limit:)
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.search error: #{e.message}"
      { 'total' => 0, 'result' => [] }
    end

    # Searches CoL datasets by name string.
    #
    # Returns an array of dataset summaries, each containing at least
    # 'id', 'title', and 'alias'.
    #
    # @param q [String] dataset name search string
    # @param limit [Integer]
    # @return [Array<Hash>]
    def self.datasets(q:, limit: 20)
      # Text search by title/name.
      text_results = begin
        result = ::Colrapi.dataset(q: q, limit: limit)
        (result['result'] || []).map { |d|
          {
            'id' => d['key'].to_s,
            'title' => d['title'],
            'alias' => d['alias']
          }
        }
      rescue => e
        Rails.logger.warn "Vendor::Colrapi.datasets text search error: #{e.message}"
        []
      end

      # Direct lookup by dataset ID — `q` may itself be a key like '3LXR'.
      # Colrapi.dataset(dataset_id:) returns a single hash, not a paged result.
      direct_hit = begin
        d = ::Colrapi.dataset(dataset_id: q)
        d.is_a?(Hash) && d['key'].present? ?
          {
            'id' => d['key'].to_s,
            'title' => d['title'],
            'alias' => d['alias']
          } : nil
      rescue
        nil
      end

      seen = {}
      [direct_hit, *text_results].compact.each_with_object([]) do |d, arr|
        next if seen[d['id']]
        seen[d['id']] = true
        arr << d
      end
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
    # @param dataset_id [String] the backbone dataset taxon_id belongs to
    # @param taxon_id [String] CoL taxon ID (e.g. '6MB3T')
    # @return [Array<Hash>]
    def self.ancestors(dataset_id, taxon_id)
      ::Colrapi.taxon(
        dataset_id, taxon_id: taxon_id, subresource: 'classification'
      )
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

    # Builds an ancestor chain for external/denormed datasets by following the
    # parentId field of successive taxon records.
    #
    # External datasets (like the Mammal Diversity Database) are ingested into
    # ChecklistBank without a pre-built classification subresource.  Instead,
    # each nameusage record carries a parentId pointing to the immediate parent
    # within the same dataset.
    #
    # Returns entries in the same format as the classification subresource used
    # by ancestors():
    #   { 'id', 'name' (String, the full scientificName), 'rank', 'authorship',
    #     'label', 'labelHtml' }
    # Order is distal-first (kingdom before immediate parent), matching
    # ancestors().
    # !! The starting taxon itself is NOT included; only its ancestors are.
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
          'name'       => taxon.dig('name', 'scientificName').to_s,
          'rank'       => taxon.dig('name', 'rank'),
          'authorship' => taxon.dig('name', 'authorship'),
          'label'      => taxon.fetch('label', '').to_s,
          'labelHtml'  => taxon.fetch('labelHtml', '').to_s
        }

        current_id = taxon['parentId']
      end

      # Return distal-first (kingdom before genus) to match the classification
      # subresource order returned by ancestors().
      chain.reverse
    rescue => e
      Rails.logger.warn "Vendor::Colrapi.ancestors_via_parent_id error: #{e.message}"
      []
    end

    # Builds CoL's own classification chain for a nameusage result — pure CoL
    # data, no TaxonWorks matching.
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
    # Note: in classification entries 'name' is a plain String, not a hash: the
    # full scientific name ('Olea europaea', 'Aedes (Stegomyia)').
    #
    # @param col_result [Hash] a single entry from search['result']
    # @param dataset_id [String, nil] the dataset that was searched; falls back
    #   to DATASETS[:col]
    # @return [Hash] extension hash with :col_key, :col_name, :col_status,
    #   :col_authorship, :col_year, :col_rank, :col_code, :col_dataset_id,
    #   :non_accepted, :accepted (a synonym's accepted name: :col_name,
    #   :col_authorship) and :alignment (Array of ancestor hashes,
    #   kingdom-first, each with :rank, :col_name, :col_id, :dataset_id,
    #   :col_authorship, :above_genus_group, :rank_unknown; empty for a
    #   non-accepted name)
    def self.classified_usage(col_result, dataset_id: nil)
      col_key = col_result['id']
      col_name = protonym_name_from(col_result['name'])
      col_rank = col_result.dig('name', 'rank')&.downcase
      col_status = col_result['status']
      col_authorship = col_result.dig('name', 'authorship')
      col_year = col_result.dig('name', 'combinationAuthorship', 'year') ||
        col_result.dig('name', 'basionymOrCombinationAuthorship', 'year')

      # CoL nomenclatural code: 'zoological', 'botanical', 'bacterial', 'virus'
      col_code = col_result.dig('name', 'code')

      # Dataset used for the search (target row).
      col_dataset_id = dataset_id.presence || DATASETS[:col]

      # A non-accepted name (synonym, ambiguous synonym, misapplied, ...) gets
      # no alignment. CoL hangs it off its accepted taxon, so the only
      # classification CoL has for it is the accepted name's - which says
      # where the taxon is now, nothing about the name's own genus or family.
      non_accepted = col_status.present? &&
        !COL_ACCEPTED_STATUSES.include?(col_status.downcase)
      accepted =
        if col_status == 'synonym' && col_result['accepted']
          {
            col_name: col_result.dig('accepted', 'name', 'scientificName'),
            col_authorship: col_result.dig('accepted', 'name', 'authorship')
          }
        end

      # Ancestors come from the searched dataset, so their ids are its ids.
      ancestor_chain =
        if non_accepted || col_key.blank?
          []
        elsif col_backbone_dataset?(col_dataset_id)
          ancestors(col_dataset_id, col_key)
        else
          ancestors_via_parent_id(col_dataset_id, col_key)
        end

      # Drop 'domain', which CoL's backbone puts above kingdom in every
      # cellular lineage (Eukaryota, Bacteria, Archaea) and TaxonWorks has no
      # rank for. Other ranks TaxonWorks can't resolve (e.g. 'unranked'
      # Viruses, 'parvphylum') are kept and flagged :rank_unknown below, and
      # virus 'realm', above kingdom, is a TaxonWorks (ICVCN) rank.
      # Both ancestor sources are already distal→proximal (kingdom before
      # genus).
      ancestor_chain =
        ancestor_chain.reject { |a| a['rank']&.downcase == 'domain' }

      alignment = ancestor_chain.map do |ancestor|
        rank = ancestor['rank']&.downcase

        {
          rank:,
          # As CoL gives it ("Aedes (Stegomyia)", "Olea europaea").
          col_name: ancestor['name'],
          col_id: ancestor['id'],
          dataset_id: col_dataset_id,
          col_authorship: ancestor['authorship'].presence,
          above_genus_group: above_genus_group?(rank, col_code),
          # e.g. 'parvphylum' - can't be created (ColCreator skips it)
          rank_unknown: rank_class_for(rank, col_code:).nil?
        }
      end

      {
        col_key:, col_name:, col_status:, col_authorship:, col_year:, col_rank:,
        col_code:, col_dataset_id:, alignment:, non_accepted:,
        **(accepted ? { accepted: } : {})
      }
    end

    # Resolves a free-text name (e.g. transcribed from a specimen label) to the
    # name currently accepted by the Catalogue of Life, so a caller doesn't have
    # to look up synonymy by hand before searching TaxonWorks.
    #
    # Takes CoL's top-ranked search hit for name_string as-is (no re-scoring
    # here). When that hit is a plain synonym, follows it to its accepted
    # target; anything else resolves to itself. Ambiguous synonyms and
    # misapplied names also carry an `accepted` usage in CoL, but it's only one
    # of several possible targets, so following it would present an arbitrary
    # pick as the valid name.
    #
    # @param name_string [String]
    # @param dataset_id [String, nil] CoL dataset ID; falls back to the default
    #   hardwired ID when nil
    # @return [Hash, nil] nil when CoL has no results, else
    #   { input:, matched_name:, matched_status:, matched_col_key:,
    #     valid_name:, valid_col_key:, valid_authorship:, valid_status:,
    #     valid_col_result:, dataset_id: }
    def self.resolve_accepted_name(name_string, dataset_id: nil)
      top = search(name_string, dataset_id:, limit: 1)['result']&.first
      return nil if top.nil?

      # Full scientific name (e.g. "Homo sapiens"), not the single-word
      # component protonym_name_from extracts for building TW Protonym trees —
      # TaxonName/Otu#cached holds the full combination, so that's what a caller
      # needs to search against.
      matched_name = top.dig('name', 'scientificName')
      matched_status = top['status']
      target_dataset_id = dataset_id.presence || DATASETS[:col]
      accepted = top['accepted'] if matched_status == 'synonym'

      # The full nameusage hash for the *valid* name — CoL nests the accepted
      # usage (a complete nameusage record, same shape as a search result) right
      # on the synonym hit.
      valid_col_result = accepted || top

      {
        input: name_string,
        matched_name:,
        matched_status:,
        matched_col_key: top['id'],
        valid_name:
          accepted ? accepted.dig('name', 'scientificName') : matched_name,
        valid_col_key: accepted ? accepted['id'] : top['id'],
        valid_authorship: valid_col_result.dig('name', 'authorship'),
        valid_status:
          accepted ? (accepted['status'] || 'accepted') : matched_status,
        valid_col_result:,
        dataset_id: target_dataset_id
      }
    end

    # The TaxonWorks Protonym#name for a CoL name: the last epithet of a
    # species-group name, a subgenus's epithet, or a uninomial (genus and
    # above). CoL's scientificName is the full name ("Homo sapiens", "Aedes
    # (Stegomyia)"); CoL parses a subgenus into genus + infragenericEpithet,
    # with no uninomial.
    # Priority: infraspecificEpithet > specificEpithet > infragenericEpithet
    #   > uninomial > scientificName fallback.
    #
    # @param name_hash [Hash, nil] the 'name' sub-hash from a CoL nameusage result
    # @return [String, nil]
    def self.protonym_name_from(name_hash)
      return nil if name_hash.nil?
      name_hash['infraspecificEpithet'].presence ||
        name_hash['specificEpithet'].presence ||
        name_hash['infragenericEpithet'].presence ||
        name_hash['uninomial'].presence ||
        name_hash['scientificName']
    end

    # Maps a CoL nomenclatural code string to the TaxonWorks rank-name lookup
    # (rank name => rank_class string) for that code.
    #
    # Lookups can return nil, see COL_CODE_TO_NOMENCLATURE_CODE.
    COL_CODE_LOOKUP_MAP = {
      'zoological' => ::ICZN_LOOKUP,
      'botanical'  => ::ICN_LOOKUP,
      'bacterial'  => ::ICNP_LOOKUP,
      'virus'      => ::ICVCN_LOOKUP
    }.freeze

    # Maps a CoL nomenclatural code string to the TaxonWorks nomenclature_code
    # symbol (NomenclaturalRank.nomenclatural_code /
    # rank_class.nomenclatural_code) it corresponds to.
    #
    # Lookups can return nil: CoL may give no code for a name (name.code
    # absent), or a code not mapped here (e.g. 'cultivars',
    # 'phytosociological'). Callers must treat nil as "code unknown", not as
    # a mismatch.
    COL_CODE_TO_NOMENCLATURE_CODE = {
      'zoological' => :iczn,
      'botanical'  => :icn,
      'bacterial'  => :icnp,
      'virus'      => :icvcn
    }.freeze

    # Maps a human-readable CoL rank string to a TaxonWorks rank_class string.
    #
    # When col_code is recognized (e.g. 'botanical' → ICN_LOOKUP), that lookup
    # is tried first so that plant names get ICN rank classes rather than ICZN
    # ones. Falls back through all four codes in order so any rank resolves if
    # possible.
    #
    # @param rank_string [String, nil] e.g. 'genus', 'family'
    # @param col_code [String, nil] 'zoological', 'botanical', 'bacterial',
    #   'virus'
    # @return [String, nil] a TaxonWorks rank_class string, or nil for an
    #   unknown rank
    def self.rank_class_for(rank_string, col_code: nil)
      return nil if rank_string.blank?
      r = rank_string.to_s.downcase

      primary = COL_CODE_LOOKUP_MAP[col_code]
      lookups =
        [primary, *COL_CODE_LOOKUP_MAP.values.excluding(primary)].compact
      lookups.each do |lookup|
        result = lookup[r]
        return result if result
      end

      nil
    end

    # Maps a CoL rank name ('genus', 'family', …) and CoL nomenclatural code
    # ('zoological', 'botanical', 'bacterial', 'virus') to the TaxonWorks RANK_SORT
    # index. Higher index = more specific rank. Returns nil when unresolvable.
    #
    # Unlike rank_class_for, doesn't fall back through the other codes: callers
    # compare these indices against each other, so all must come from one code.
    # An unrecognized col_code is treated as zoological.
    def self.col_rank_sort(rank_name, col_code)
      return nil if rank_name.blank?
      lookup = COL_CODE_LOOKUP_MAP[col_code] || ::ICZN_LOOKUP
      rank_class = lookup[rank_name]
      rank_class ? ::RANK_SORT[rank_class] : nil
    end

    # True when rank_name resolves to FamilyGroup or above
    # (HigherClassificationGroup) — i.e. strictly coarser than GenusGroup — for
    # the given CoL nomenclatural code. Unresolvable ranks are treated as
    # not-above (false).
    def self.above_genus_group?(rank_name, col_code)
      rank_class = rank_class_for(rank_name, col_code:)
      rank_class ? ::FAMILY_AND_ABOVE_RANK_NAMES.include?(rank_class) : false
    end
  end

end
