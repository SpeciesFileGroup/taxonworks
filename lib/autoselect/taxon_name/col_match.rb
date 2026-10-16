# lib/autoselect/taxon_name/col_match.rb

# Matches one Catalogue of Life nameusage against a project's TaxonNames and
# builds the autoselect pseudo-record for it: CoL's own data and
# classification (Vendor::Colrapi.classified_usage) plus how each row lines
# up with TaxonWorks, whether the target already exists, and anything that
# blocks Create (conflicts, homonyms).
#
# Terms:
#   * target - the CoL name being matched (the last row of the chain, below
#     its ancestors)
#   * anchor - the lowest row of CoL's chain (the target, else its nearest
#     ancestor) that exactly one TaxonName in the project matches, by current
#     form, rank and code. TaxonWorks' lineage is compared to CoL's from there
#     up. No anchor: Create would make the whole chain.
#
class Autoselect::TaxonName::ColMatch

  # @param col_result [Hash] a flat CoL nameusage hash (search-result shape)
  # @param project_id [Integer]
  # @param dataset_id [String, nil]
  def initialize(col_result, project_id:, dataset_id: nil)
    raise ArgumentError, 'project_id is required' if project_id.blank?

    @col_result = col_result
    @project_id = project_id
    @dataset_id = dataset_id
  end

  # @return [OpenStruct, nil] pseudo-record compatible with TaxonName
  #   autoselect format_results; nil when the usage has no scientificName
  def call
    # Flat nameusage structure: 'id', 'status', 'name' hash, 'label',
    # 'labelHtml'
    col_name = @col_result.dig('name', 'scientificName')
    return nil if col_name.blank?

    col_rank = @col_result.dig('name', 'rank')&.downcase
    extension = ::Vendor::Colrapi.classified_usage(
      @col_result, dataset_id: @dataset_id
    )

    # Flag when the target's rank is not resolvable in TaxonWorks (e.g.
    # 'domain').
    if !rank_resolvable?(col_rank)
      extension = extension.merge(target_rank_unknown: true)
    end

    extension = extension.merge(
      match_against_taxonworks(extension, col_name, col_rank)
    )

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

  # Finds the anchor, walking up from the target, then diffs TaxonWorks' REAL
  # ancestor chain from there against CoL's (ColAncestryComparator).
  #
  # A position with more than one same-name, same-rank candidate is a homonym we
  # have no principled way to pick between (matching by cached name alone never
  # guaranteed a coherent chain) — that stops the walk and blocks Create, same
  # as a real conflict.
  #
  # @return [Hash] :alignment (kingdom-first, ancestors only — the target is
  #   reported separately below), :chain_consistent, :target_taxonworks_id,
  #   :target_global_id (only when the target itself matched), :ambiguous_match
  #   (only when the walk was stopped by a homonym), :authorship_mismatch (see
  #   #authorship_mismatch)
  def match_against_taxonworks(extension, col_name, col_rank)
    full_chain = extension[:alignment] + [{
      rank: col_rank,
      col_name:,
      col_id: extension[:col_key],
      dataset_id: extension[:col_dataset_id],
      col_authorship: extension[:col_authorship]
    }]

    anchor_index, anchor_candidates =
      find_anchor(full_chain, extension[:col_code])

    if anchor_candidates && anchor_candidates.length > 1
      return ambiguous_result(
        extension, full_chain[anchor_index], anchor_candidates.length
      )
    end

    anchor = anchor_candidates&.first
    if anchor.nil?
      none_alignment = extension[:alignment].map do |row|
        row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
      end
      return { alignment: none_alignment, chain_consistent: true }
    end

    # Rows Create would make: everything below the anchor (none when the
    # target matched).
    #
    # TODO: a row here whose name TaxonWorks has only in its published form is
    # created again, as CoL places it - a duplicate of the taxon, under a
    # hierarchy TaxonWorks' data says is out of date. Not checked for now: the
    # Smart level, which usually runs first, already lists such a name for the
    # target (it searches original combinations), and it's rare.
    below_rows = full_chain[(anchor_index + 1)..].map do |row|
      row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
    end

    tw_chain = anchor.self_and_ancestors
      .where.not(rank_class: 'NomenclaturalRank') # excludes Root
      .unscope(:order)
      .order(generations: :desc)
      .to_a

    diffed = ::Autoselect::TaxonName::ColAncestryComparator.new(
      tw_chain:,
      col_chain: full_chain[0..anchor_index],
      col_code: extension[:col_code]
    ).call

    merged = diffed + below_rows
    mismatch = authorship_mismatch(anchor, full_chain[anchor_index])

    {
      alignment: merged[0...-1],
      chain_consistent: merged.none? { |row| row[:match] == 'conflict' },
      **(mismatch ? { authorship_mismatch: mismatch } : {}),
      **(
        if below_rows.empty?
          {
            target_taxonworks_id: anchor.id,
            target_global_id: anchor.to_global_id.to_s
          }
        else
          {}
        end
      )
    }
  end

  # Walks CoL's chain up from the target to the first row any TaxonName
  # matches, by current form, rank and code. One match there is the anchor.
  # More than one is a homonym: the one whose authorship agrees with CoL's is
  # the anchor (#agreeing_authorship), else the caller can't pick between
  # them. A lone match is taken whatever its authorship, a difference is only
  # reported (#authorship_mismatch).
  #
  # Only the current form counts: a name matching in its *published* form (a
  # Protonym's original combination, or a Combination) is a taxon TaxonWorks
  # places differently, and its lineage would conflict with CoL's.
  #
  # TODO: still missed - the same genus-group name at another genus-group rank
  # (CoL genus Erasmoneura vs TaxonWorks subgenus Erythroneura (Erasmoneura)):
  # rank must match exactly.
  #
  # @param full_chain [Array<Hash>] CoL's chain, kingdom-first, target last
  # @param col_code [String, nil] CoL nomenclatural code ('zoological', ...)
  # @return [Array, nil] [index into full_chain, Array<TaxonName>] for that
  #   row, or nil when no row matches
  def find_anchor(full_chain, col_code)
    # CoL and TaxonWorks format some names differently (subgenus, species-group
    # names with/without subgenus, [sic]), so candidates are found and compared
    # by key.
    candidates_by_key = ::Vendor::Colrapi::NameTranslation
      .candidates_by_key(full_chain, project_id: @project_id)
    expected_code =
      ::Vendor::Colrapi::COL_CODE_TO_NOMENCLATURE_CODE[col_code]

    (full_chain.length - 1).downto(0) do |i|
      row = full_chain[i]
      candidates = candidates_for(
        candidates_by_key, row, :current, expected_code
      )
      next if candidates.empty?

      if candidates.length > 1
        candidates = agreeing_authorship(candidates, row[:col_authorship])
      end
      return [i, candidates]
    end
    nil
  end

  # Authorship only ever turns a block into a match: anything it can't compare
  # (no year, an abbreviation, a diacritic or date that differs) leaves all
  # the candidates.
  #
  # @param col_authorship [String, nil] as CoL gives it, e.g. "(Walker, 1851)"
  # @return [Array<TaxonName>] the one candidate whose authorship agrees with
  #   CoL's (with parentheses, then without), else all of them
  def agreeing_authorship(candidates, col_authorship)
    col_authorship_key = ::Utilities::AuthorNames.authorship_key(col_authorship)
    return candidates if col_authorship_key.nil?

    candidate_keys = candidates.to_h do |taxon_name|
      [
        taxon_name,
        ::Utilities::AuthorNames.authorship_key(taxon_name.cached_author_year)
      ]
    end

    [true, false].each do |parentheses|
      agreeing = candidates.select do |taxon_name|
        ::Utilities::AuthorNames.same_authorship?(
          candidate_keys[taxon_name], col_authorship_key, parentheses:
        )
      end
      return agreeing if agreeing.length == 1
    end
    candidates
  end

  # The anchor is matched by name, rank and code alone; when its authorship
  # and CoL's can both be compared and differ, CoL may mean a different taxon
  # with the same name (e.g. CoL's "Trioza minuta Crawford, 1910", a synonym of
  # Bactericera minuta, anchors on TaxonWorks' Trioza minuta (Mathur, 1975)).
  # Reported, not blocked: a formatting difference reads the same way.
  # Parentheses are ignored, CoL adds them by its own placement.
  #
  # @param row [Hash] the anchor's row of the CoL chain
  # @return [Hash, nil] { rank:, col_name:, col_authorship:,
  #   taxonworks_name:, taxonworks_authorship: }
  def authorship_mismatch(anchor, row)
    col_authorship_key =
      ::Utilities::AuthorNames.authorship_key(row[:col_authorship])
    anchor_authorship_key =
      ::Utilities::AuthorNames.authorship_key(anchor.cached_author_year)
    return nil if col_authorship_key.nil? || anchor_authorship_key.nil?

    same = ::Utilities::AuthorNames
      .same_authorship?(anchor_authorship_key, col_authorship_key)
    return nil if same

    {
      rank: row[:rank],
      col_name: row[:col_name],
      col_authorship: row[:col_authorship],
      taxonworks_name: anchor.cached,
      taxonworks_authorship: anchor.cached_author_year
    }
  end

  # The TaxonNames whose given form (:current or :published) is a CoL row, at
  # the row's rank (and code, when CoL gives one). Rank is checked here, per
  # row, not by key: a genus and its nominotypical subgenus share a key.
  #
  # @param candidates_by_key [Hash] from NameTranslation.candidates_by_key
  # @param row [Hash] a row of the CoL alignment chain
  # @param form [Symbol] :current or :published (see NameTranslation.forms)
  # @param expected_code [Symbol, nil] nomenclatural code CoL gives, if any
  # @return [Array<TaxonName>]
  def candidates_for(candidates_by_key, row, form, expected_code)
    key = ::Vendor::Colrapi::NameTranslation
      .col_name_key(row[:col_name], row[:rank])

    (candidates_by_key[key] || [])
      .select { |candidate| candidate.form == form }
      .map(&:taxon_name)
      .select do |taxon_name|
        rank_name, code = rank_name_and_code(taxon_name)
        rank_name == row[:rank] &&
          (expected_code.nil? || code == expected_code)
      end
  end

  # A Combination has no rank_class of its own: its rank is that of its
  # finest element (Combination#inferred_rank), its code that element's
  # Protonym's.
  #
  # @return [Array] [rank name, nomenclatural code symbol], or [nil, nil]
  def rank_name_and_code(taxon_name)
    if taxon_name.is_a?(::Combination)
      protonym = taxon_name.finest_protonym
      return [nil, nil] if protonym.nil?

      [taxon_name.inferred_rank, protonym.rank_class.nomenclatural_code]
    else
      [
        rank_name_for(taxon_name.rank_class),
        taxon_name.rank_class.nomenclatural_code
      ]
    end
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

  def rank_resolvable?(rank_string)
    return false if rank_string.blank?
    r = rank_string.to_s.downcase
    ::Vendor::Colrapi::COL_CODE_LOOKUP_MAP.values.any? do |lookup|
      lookup[r].present?
    end
  end

end
