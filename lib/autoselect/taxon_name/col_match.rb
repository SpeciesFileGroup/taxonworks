# lib/autoselect/taxon_name/col_match.rb

# Matches one Catalogue of Life nameusage against a project's TaxonNames and
# builds the autoselect pseudo-record for it: CoL's own data and
# classification (Vendor::Colrapi.classified_usage) plus how each row lines
# up with TaxonWorks, whether the target already exists, and anything that
# blocks Create (conflicts, homonyms, possible duplicates).
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
  # @return [Hash] :alignment (kingdom-first, ancestors only — the target is
  #   reported separately below), :chain_consistent, :target_taxonworks_id,
  #   :target_global_id (only when the target itself matched), :ambiguous_match
  #   (only when the walk was stopped by a homonym), :possible_duplicates and
  #   :possible_duplicates_of ({ rank:, col_name: } of the row they duplicate)
  #   (only when a row Create would make is already in TaxonWorks)
  def match_against_taxonworks(extension, col_name, col_rank)
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
      translation.candidates_by_key(full_chain, project_id: @project_id)

    # A CoL name can also match a TaxonWorks name in its *published* form (a
    # Protonym's original combination, or a Combination) - a taxon TaxonWorks
    # already has but places differently. Such a hit never becomes the anchor
    # (its TaxonWorks lineage is the current placement, which conflicts with
    # CoL's): when a row Create would make (below the anchor) has one, it's
    # reported as :possible_duplicates and the modal blocks Create.
    #
    # TODO: still missed - the same genus-group name at another genus-group rank
    # (CoL genus Erasmoneura vs TaxonWorks subgenus Erythroneura (Erasmoneura)):
    # rank must match exactly below.
    expected_nomenclature_code =
      ::Vendor::Colrapi::COL_CODE_TO_NOMENCLATURE_CODE[extension[:col_code]]

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
          candidate.rank_class.nomenclatural_code == expected_nomenclature_code
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

    # Rows Create would make: everything below the anchor (none when the
    # target matched). The first one TaxonWorks already has in another form
    # is reported - anything below it would be created under the duplicate.
    created_rows = full_chain[(anchor_index.nil? ? 0 : anchor_index + 1)..]
    duplicates_entry = {}
    created_rows.each do |row|
      duplicates = possible_duplicates(
        candidates_by_key, row, expected_nomenclature_code
      )
      next if duplicates.empty?

      duplicates_entry = {
        possible_duplicates: duplicates,
        possible_duplicates_of: { rank: row[:rank], col_name: row[:col_name] }
      }
      break
    end

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

    below_anchor = created_rows.map do |row|
      row.merge(taxonworks_id: nil, taxonworks_name: nil, match: 'none')
    end

    merged = diffed + below_anchor

    {
      alignment: merged[0...-1],
      chain_consistent: merged.none? { |row| row[:match] == 'conflict' },
      **duplicates_entry,
      **(
        if created_rows.empty?
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

  # TaxonWorks names whose *published* form (see
  # Vendor::Colrapi::NameTranslation.forms) is a CoL row, at the row's rank
  # (and code, when CoL gives one): a Protonym whose original combination it
  # is, or a Combination. Mostly species-group names, but a family-group
  # name's original form ("Aphrophorides" for Aphrophoridae) counts too.
  #
  # TODO: authorship isn't compared, so a primary homonym (CoL Aus bus Jones,
  # 1950 vs TaxonWorks Cus bus (Smith, 1900), originally Aus bus) is reported
  # and Create is blocked with no override. Options: show authorship in the
  # modal; filter on author/year; or downgrade to a warning when authorship
  # clearly differs.
  #
  # @param candidates_by_key [Hash] from NameTranslation.candidates_by_key
  # @param row [Hash] a row of the CoL alignment chain
  # @param expected_code [Symbol, nil] nomenclatural code CoL gives, if any
  # @return [Array<Hash>] { id:, global_id:, cached:, via:
  #   'original_combination' | 'combination', published:, valid_id:,
  #   valid_cached: (nil when it's its own valid name) }
  def possible_duplicates(candidates_by_key, row, expected_code)
    key = ::Vendor::Colrapi::NameTranslation
      .col_name_key(row[:col_name], row[:rank])

    (candidates_by_key[key] || [])
      .select { |candidate| candidate.form == :published }
      .map(&:taxon_name)
      .select do |taxon_name|
        rank_name, code = rank_name_and_code(taxon_name)
        rank_name == row[:rank] &&
          (expected_code.nil? || code == expected_code)
      end
      .map { |taxon_name| duplicate_entry(taxon_name) }
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

  def duplicate_entry(taxon_name)
    valid_id = taxon_name.cached_valid_taxon_name_id
    if valid_id && valid_id != taxon_name.id
      valid = ::TaxonName.find_by(id: valid_id)
    end
    combination = taxon_name.is_a?(::Combination)
    published = ::Vendor::Colrapi::NameTranslation.forms(taxon_name)[:published]

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

  def rank_resolvable?(rank_string)
    return false if rank_string.blank?
    r = rank_string.to_s.downcase
    ::Vendor::Colrapi::COL_CODE_LOOKUP_MAP.values.any? do |lookup|
      lookup[r].present?
    end
  end

end
