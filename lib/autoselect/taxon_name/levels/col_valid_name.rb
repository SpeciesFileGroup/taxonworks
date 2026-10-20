# lib/autoselect/taxon_name/levels/col_valid_name.rb
# Resolves a term through Catalogue of Life synonymy to its accepted names,
# then reuses ColMatch for the actual alignment/extension data and
# existing-TaxonName check — feeding it the accepted nameusage hashes that
# resolve_accepted_names already returned, so no second CoL search is needed.
#
# Returns one record per accepted name the term resolves to (usually one;
# homonyms give several, see Vendor::Colrapi.resolve_accepted_names) — a CoL
# pseudo-record flagged with `resolved_from:` so the confirmation UI can show
# it's the accepted name for what was typed, not a literal search match.
# It's a CoL record even when the name is already a TaxonName in the
# project, so the confirmation UI can still show (and offer to create)
# missing ancestors.
#
# Autoselect::Otu::Levels::ColValidName reuses #resolve_targets directly
# and adds its own existing-Otu hook.
class Autoselect::TaxonName::Levels::ColValidName < ::Autoselect::Level
  include ::Autoselect::Levels::ColResolvedName
  include ::Autoselect::Levels::ColRecordLabel

  def key
    :col_valid_name
  end

  def label
    'CoL Valid Name'
  end

  def description
    'Resolve the term through Catalogue of Life synonymy to its ' \
      'accepted name.'
  end

  def external?
    true
  end

  # Searches with the CoL dataset chosen for the catalogue_of_life level.
  def options_level
    :catalogue_of_life
  end

  # Opt-in only — fast/smart/catalogue_of_life cover the common cases;
  # this stays present-but-unchecked in the preferences modal until a
  # user opts in.
  def is_default
    false
  end

  # @param term [String]
  # @param project_id [Integer, nil]
  # @param dataset_id [String, nil] CoL dataset ID from user preferences;
  #   falls back to default when nil
  # @return [Array<OpenStruct>] a CoL result per resolved valid name (its
  #   target_taxonworks_id set when the name already exists)
  def call(
    term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil,
    **_kwargs
  )
    resolve_targets(term, project_id:, dataset_id:)
  end

  # The resolved pseudo-records — each accepted name's CoL
  # alignment/extension data plus ColMatch's existing-TaxonName check, marked
  # with their code when they span more than one (ColCodeBadge). Empty when
  # CoL resolves nothing usable.
  #
  # The extension's `resolved_from` is term; when CoL followed synonymy,
  # `resolved_synonym` holds the synonym it matched, with its authorship
  # (nil otherwise), and `resolved_ambiguous` is true when that synonym is
  # an ambiguous one (this is only one of its valid names).
  #
  # @return [Array<OpenStruct>]
  def resolve_targets(term, project_id:, dataset_id: nil)
    targets = ::Vendor::Colrapi.resolve_accepted_names(term, dataset_id:)
      .filter_map do |resolved|
        next if resolved[:valid_name].blank? ||
          resolved[:valid_col_result].blank?

        target = ::Autoselect::TaxonName::ColMatch.new(
          resolved[:valid_col_result],
          project_id:,
          dataset_id: resolved[:dataset_id]
        ).call
        next if target.nil?

        followed = resolved[:matched_col_key] != resolved[:valid_col_key]
        resolved_synonym =
          if followed
            [resolved[:matched_name], resolved[:matched_authorship]]
              .compact.join(' ')
          end
        resolved_ambiguous =
          followed && resolved[:matched_status] == 'ambiguous synonym'
        target._col_extension = target._col_extension.merge(
          resolved_from: term, resolved_synonym:, resolved_ambiguous:
        )

        target
      end

    ::Autoselect::Levels::ColCodeBadge.mark(targets)
  end

end
