# lib/autoselect/taxon_name/levels/catalogue_of_life.rb
class Autoselect::TaxonName::Levels::CatalogueOfLife < ::Autoselect::Level
  include ::Autoselect::Levels::ColRecordInfo

  def key
    :catalogue_of_life
  end

  def label
    'Catalogue of Life'
  end

  def description
    'Search the Catalogue of Life for matching names. Returns external ' \
      'results with alignment data for confirmation.'
  end

  def external?
    true
  end

  def record_label(record)
    [record.cached.to_s.presence, col_author_year(record)]
      .compact
      .join(' ')
  end

  def record_label_html(record, term = nil)
    [record.cached.to_s.presence, col_author_year(record)]
      .compact
      .map { |part| ERB::Util.html_escape(part) }
      .join(' ')
  end

  # @param term [String]
  # @param project_id [Integer, nil]
  # @param dataset_id [String, nil] CoL dataset ID from user preferences;
  #   falls back to default when nil
  # @return [Array<OpenStruct>] pseudo-records compatible with TaxonName
  #   autoselect format_results
  def call(
    term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil,
    **_kwargs
  )
    raw = ::Vendor::Colrapi.search(term, dataset_id:)
    results = raw['result'] || []
    return [] if results.empty?

    results.filter_map do |col_result|
      build_pseudo_record(col_result, project_id:, dataset_id:)
    end
  end

  # Builds one autoselect pseudo-record (alignment + existing-TaxonName check)
  # from a raw CoL nameusage hash.
  #
  # @param col_result [Hash] a flat CoL nameusage hash (search-result shape)
  # @param project_id [Integer, nil]
  # @param dataset_id [String, nil]
  # @return [OpenStruct, nil] pseudo-record compatible with TaxonName
  #   autoselect format_results; nil when the usage has no scientificName
  def build_pseudo_record(col_result, project_id: nil, dataset_id: nil)
    # Flat nameusage structure: 'id', 'status', 'name' hash, 'label',
    # 'labelHtml'
    col_name = col_result.dig('name', 'scientificName')
    return nil if col_name.blank?

    col_rank = col_result.dig('name', 'rank')&.downcase
    if col_rank == 'subgenus'
      col_name =
        ::Vendor::Colrapi::NameTranslation.subgenus_epithet(col_name)
    end
    extension = ::Vendor::Colrapi.build_extension(col_result, dataset_id:)

    # Flag when the target's rank is not resolvable in TaxonWorks (e.g.
    # 'domain'). ColCreator silently skips such rows, so the modal needs
    # to know up-front.
    if !rank_resolvable?(col_rank)
      extension = extension.merge(target_rank_unknown: true)
    end

    if project_id.present?
      extension = extension.merge(
        match_against_taxonworks(
          extension, col_name, col_rank, project_id
        )
      )
    end

    OpenStruct.new(
      id: nil,
      cached: col_name,
      name: col_name,
      rank_string: nil,
      cached_valid_taxon_name_id: nil,
      _col_extension: extension
    )
  end

  private

  # Finds the lowest (most specific) rank in the CoL chain — the target itself
  # first, then ancestors from most- to least-proximal — that unambiguously
  # (exactly one candidate, matched on both name AND rank) exists in this
  # project, then diffs TaxonWorks' REAL ancestor chain from there against CoL's
  # (ColAncestryComparator).
  #
  # This never reparents anything: the target, if it exists at all, is checked
  # first and immediately becomes the anchor, so TaxonWorks' own real ancestor
  # chain — not a separately-found, name-coincidental chain — is always the
  # source of truth for it. Only when the target itself doesn't exist yet does
  # the search continue outward, since attaching a brand-new record to an
  # existing, unambiguous ancestor is a normal creation decision, not a
  # reparenting of anything that already exists.
  #
  # A position with more than one same-name, same-rank candidate is a homonym we
  # have no principled way to pick between (matching by cached name alone never
  # guaranteed a coherent chain) — that stops the walk and blocks Create, same
  # as a real conflict.
  #
  # @return [Hash] merges into the extension: :alignment (kingdom-first,
  #   ancestors only — the target is reported separately below),
  #   :chain_consistent, :target_taxonworks_id, :target_global_id (only when the
  #   target itself matched), :ambiguous_match (only when the walk was stopped
  #   by a homonym)
  def match_against_taxonworks(extension, col_name, col_rank, project_id)
    full_chain = extension[:alignment] + [{
      rank: col_rank,
      col_name:,
      col_id: extension[:col_key],
      dataset_id: extension[:col_dataset_id],
      col_authorship: extension[:col_authorship]
    }]

    # CoL and TaxonWorks format some names differently (subgenus, species-group
    # names with/without subgenus, [sic]), so candidates are found and compared
    # by key - see Vendor::Colrapi::NameTranslation.
    translation = ::Vendor::Colrapi::NameTranslation
    candidates_by_key =
      translation.candidates_by_key(full_chain, project_id:)

    # A CoL name can also match a TaxonWorks name in its *published* form (a
    # Protonym's original combination, or a Combination) - a taxon TaxonWorks
    # already has but places differently. Such a hit never becomes the anchor
    # (its TaxonWorks lineage is the current placement, which conflicts with
    # CoL's): when the target has no current-form match it's reported as
    # :possible_duplicates and the modal blocks Create.
    #
    # TODO: still missed - the same genus-group name at another genus-group rank
    # (CoL genus Erasmoneura vs TaxonWorks subgenus Erythroneura (Erasmoneura)):
    # rank must match exactly below.

    # When CoL tells us the code, require candidates to match it too —
    # same-name, same-rank homonyms do occur across codes (e.g. a zoological vs
    # a botanical genus sharing a name), and this is the only point that needs
    # the check: once an anchor is chosen, TaxonName's own
    # validate_same_nomenclatural_code already guarantees every real ancestor
    # above it shares its code, so nothing further down this method needs to
    # re-check it.
    expected_nomenclature_code =
      ::Vendor::Colrapi::COL_CODE_TO_NOMENCLATURE_CODE[
        extension[:col_code]
      ]

    anchor = nil
    anchor_index = nil

    (full_chain.length - 1).downto(0) do |i|
      row = full_chain[i]
      row_key = translation.col_name_key(row[:col_name], row[:rank])
      rank_matched = (candidates_by_key[row_key] || [])
        .select { |candidate| candidate.form == :current }
        .map(&:taxon_name)
        .select do |candidate|
          rank_name_for(candidate.rank_class) == row[:rank]
        end

      if expected_nomenclature_code
        rank_matched = rank_matched.select do |candidate|
          candidate.rank_class.nomenclatural_code ==
            expected_nomenclature_code
        end
      end

      if rank_matched.length > 1
        return ambiguous_result(extension, row, rank_matched.length)
      elsif rank_matched.length == 1
        anchor = rank_matched.first
        anchor_index = i
        break
      end
    end

    target_row = full_chain.last
    target_key =
      translation.col_name_key(target_row[:col_name], target_row[:rank])
    duplicates = possible_duplicates(
      candidates_by_key[target_key] || [],
      target_row,
      expected_nomenclature_code
    )
    duplicates_entry =
      duplicates.any? ? { possible_duplicates: duplicates } : {}

    if anchor.nil?
      none_alignment = extension[:alignment].map do |row|
        row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
      end
      return {
        alignment: none_alignment,
        chain_consistent: true,
        **duplicates_entry
      }
    end

    # self_and_ancestors carries its own baked-in default order, which .order()
    # only appends to (doesn't replace) — unscope it first, same as
    # TaxonName#safe_self_and_ancestors already does, to actually get
    # kingdom-first. The rank_class condition excludes the project root.
    tw_chain = anchor.self_and_ancestors
      .where.not(rank_class: 'NomenclaturalRank')
      .unscope(:order)
      .order(generations: :desc)
      .to_a

    diffed = ::Autoselect::TaxonName::ColAncestryComparator.new(
      tw_chain:,
      col_chain: full_chain[0..anchor_index],
      col_code: extension[:col_code]
    ).call

    below_anchor = full_chain[(anchor_index + 1)..].map do |row|
      row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
    end

    merged = diffed + below_anchor
    target_matched = anchor_index == full_chain.length - 1

    {
      alignment: merged[0...-1],
      chain_consistent: merged.none? { |row| row[:match] == 'conflict' },
      **(
        if target_matched
          {
            target_taxonworks_id: anchor.id,
            target_global_id: anchor.to_global_id.to_s
          }
        else
          duplicates_entry
        end
      )
    }
  end

  # TaxonWorks names whose *published* form (see
  # Vendor::Colrapi::NameTranslation.forms) is the CoL target: a Combination, or
  # a Protonym at the target's rank (and code, when CoL gives one) whose
  # original combination it is.
  #
  # @param candidates [Array<NameTranslation::Candidate>] the target's
  #   name-key matches, from NameTranslation.candidates_by_key
  # @param target_row [Hash] the last (target) row of the CoL alignment chain
  # @param expected_code [Symbol, nil] nomenclatural code CoL gives, if any
  # @return [Array<Hash>] { id:, global_id:, cached:, via:
  #   'original_combination' | 'combination', published:, valid_id:,
  #   valid_cached: (nil when it's its own valid name) }
  def possible_duplicates(candidates, target_row, expected_code)
    candidates
      .select { |candidate| candidate.form == :published }
      .map(&:taxon_name)
      .select do |taxon_name|
        next true if taxon_name.is_a?(::Combination)

        rank_name_for(taxon_name.rank_class) == target_row[:rank] &&
          (expected_code.nil? ||
            taxon_name.rank_class.nomenclatural_code == expected_code)
      end
      .map { |taxon_name| duplicate_entry(taxon_name) }
  end

  def duplicate_entry(taxon_name)
    valid_id = taxon_name.cached_valid_taxon_name_id
    if valid_id && valid_id != taxon_name.id
      valid = ::TaxonName.find_by(id: valid_id)
    end
    combination = taxon_name.is_a?(::Combination)
    published =
      ::Vendor::Colrapi::NameTranslation.forms(taxon_name)[:published]

    {
      id: taxon_name.id,
      global_id: taxon_name.to_global_id.to_s,
      cached: taxon_name.cached,
      via: combination ? 'combination' : 'original_combination',
      published:,
      valid_id: valid&.id,
      valid_cached: valid&.cached
    }
  end

  def rank_name_for(rank_class)
    ::RANKS_LOOKUP[rank_class.to_s]
  end

  def ambiguous_result(extension, row, count)
    none_alignment = extension[:alignment].map do |r|
      r.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
    end
    {
      alignment: none_alignment,
      chain_consistent: false,
      ambiguous_match: {
        rank: row[:rank], col_name: row[:col_name], count:
      }
    }
  end

  # The display author+year for a CoL result.
  #
  # CoL renders a recombination's authorship as the original (basionym)
  # author+year wrapped in parens, followed by the combination authorship, e.g.
  # "(Chatton, 1925) Whittaker & Margulis, 1978". Per ICZN convention we show
  # only the original author+year, keeping the parens that signal the
  # recombination. A name described in its original genus has no leading
  # parenthetical and is shown verbatim, e.g. "Linnaeus, 1758".
  #
  # @return [String, nil]
  def col_author_year(record)
    ext = record._col_extension
    return nil unless ext

    authorship = ext[:col_authorship].presence
    return nil unless authorship

    if (leading_parenthetical = authorship[/\A\([^)]*\)/])
      leading_parenthetical
    else
      authorship
    end
  end

  def rank_resolvable?(rank_string)
    return false if rank_string.blank?
    r = rank_string.to_s.downcase
    ::Vendor::Colrapi::COL_CODE_LOOKUP_MAP.values.any? do |lookup|
      lookup[r].present?
    end
  end

end
