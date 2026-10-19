# lib/autoselect/taxon_name/levels/col_valid_name.rb
# Resolves a term through Catalogue of Life synonymy to its accepted name,
# then reuses ColMatch for the actual alignment/extension data and
# existing-TaxonName check — feeding it the accepted nameusage hash that
# resolve_accepted_name already returned, so no second CoL search (and no
# per-result classification fetch) is needed.
#
# Returns at most one record — a CoL pseudo-record for the resolved valid
# name, flagged with `resolved_from:` so the confirmation UI can show
# it's the accepted name for what was typed, not a literal search match.
# It's a CoL record even when the name is already a TaxonName in the
# project, so the confirmation UI can still show (and offer to create)
# missing ancestors.
#
# Autoselect::Otu::Levels::ColValidName reuses #resolve_target directly
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
  # @return [Array<OpenStruct>] a single CoL result for the resolved valid
  #   name (its target_taxonworks_id set when the name already exists)
  def call(
    term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil,
    **_kwargs
  )
    target = resolve_target(term, project_id:, dataset_id:)
    target ? [target] : []
  end

  # The resolved pseudo-record — the accepted name's CoL alignment/extension
  # data plus ColMatch's existing-TaxonName check. nil when CoL resolves
  # nothing usable.
  #
  # The extension's `resolved_from` is term; when CoL followed synonymy,
  # `resolved_synonym` holds the synonym it matched (nil otherwise).
  #
  # @return [OpenStruct, nil]
  def resolve_target(term, project_id:, dataset_id: nil)
    resolved = ::Vendor::Colrapi.resolve_accepted_name(term, dataset_id:)
    return nil if resolved.nil? ||
      resolved[:valid_name].blank? ||
      resolved[:valid_col_result].blank?

    target = ::Autoselect::TaxonName::ColMatch.new(
      resolved[:valid_col_result],
      project_id:,
      dataset_id: resolved[:dataset_id]
    ).call
    return nil if target.nil?

    followed = resolved[:matched_col_key] != resolved[:valid_col_key]
    resolved_synonym = followed ? resolved[:matched_name] : nil
    target._col_extension =
      target._col_extension.merge(resolved_from: term, resolved_synonym:)

    target
  end

end
