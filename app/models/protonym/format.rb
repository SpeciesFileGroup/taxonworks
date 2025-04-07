# Methods for constructing names from the graph of data.
module Protonym::Format
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  # !! TODO: Higher classification does not follow the same pattern
  # !! TODO: when name is a subgenus will not grab genus (still true?)
  #
  #
  # Conceptually there are 2 objects required to build @taxonomy,
  # one for the scientific name, the other for the higher taxa.
  # These need to be kept seperately in terms of optimizing
  # queries, or at least isolatable if combined.
  #
  # This method covers scientific name, gathering all string
  # elements, including 'sic' etc., and pointing to them
  # by rank. It therefor sits between model/helper.
  #
  # @!return [ { rank => [prefix, name] } ]
  #    for genus and below:
  #
  # @taxon_name.full_name_hash # =>
  #      { "family' => 'Gidae',
  #        "genus" => [nil, "Aus"],  # Note Array!
  #        "subgenus" => [nil, "Aus"],
  #        "section" => ["sect.", "Aus"],
  #        "series" => ["ser.", "Aus"],
  #        "species" => [nil, "aaa"],
  #        "subspecies" => [nil, "bbb"],
  #        "variety" => ["var.", "ccc"]}
  #
  #        # TODO: document 'sic', it should be third placement
  #
  def full_name_hash
    gender = nil
    data = {}

    # We shouldn't need safe here, this is after writing
    # We also don't require ordering
    self_and_ancestors.unscope(:order).each do |i|
      # safe_self_and_ancestors.each do |i|
      rank = i.rank
      gender = i.cached_gender if rank == 'genus'

      if i.is_genus_or_species_rank?
        if ['genus', 'subgenus', 'species', 'subspecies'].include?(rank) && rank_string =~ /Iczn/

          data[rank] = [nil, i.name_with_misspelling(gender)]

        elsif ['genus', 'subgenus', 'species'].include?(rank)
          data[rank] = [nil, i.name_with_misspelling(gender)]
        else
          data[rank] = [i.rank_class.abbreviation, i.name_with_misspelling(gender)]
        end
      else
        data[rank] = i.name
      end
    end

    # Only check for these ranks
    if TaxonName::COMBINATION_ELEMENTS.include?(rank.to_sym)
      if data['genus'].nil?
        if original_genus
          data['genus'] = [nil, "[#{original_genus&.name}]"]
        else
          data['genus'] = [nil, '[GENUS NOT SPECIFIED]']
        end
      end

      if data['species'].nil? && (!data['subspecies'].nil? || !data['variety'].nil? || !data['subvariety'].nil? || !data['form'].nil? || !data['subform'].nil?)
        data['species'] = [nil, '[SPECIES NOT SPECIFIED]']
      end

      if !data['subvariety'].nil? && data['variety'].nil?
        data['variety'] = [nil, '[VARIETY NOT SPECIFIED]']
      end

      if !data['subform'].nil? && data['form'].nil?
        data['form'] = [nil, '[FORM NOT SPECIFIED]']
      end
    end
    data
  end

  # @return [String, nil]
  #  A monominal if names is above genus, or a full epithet if below.
  #  Does not include author_year. Does not include HTML.
  #
  #  !! Combination has its own version now.
  #
  def get_full_name
    return name_with_misspelling(nil) if !is_genus_or_species_rank?
    return name if rank_class.to_s =~ /Icvcn/
    ::Utilities::Nomenclature.full_name(full_name_hash, rank: rank_name, non_binomial: not_binominal? )
  end

  def get_original_combination
    return verbatim_name if !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string) && !verbatim_name.nil?
    e = original_combination_elements
    return nil if e.none?

    # Weird, why?
    # DD: in ICVCN the species name is "Potato spindle tuber viroid", the genus name is only used for classification...
    #
    # @proceps: then we should exclude or alter elements before we get to this point, not here, so that the renderer still works, exceptions at this point are bad
    # and this didn't do what you think it did, it's was returning an Array of two things
    return e[:species][1] if rank_class.to_s =~ /Icvcn/

    p = TaxonName::COMBINATION_ELEMENTS.inject([]){|ary, r| ary.push(e[r]) }

    s = p.flatten.compact.join(' ')
    @_cached_build_state[:original_combination] = s.presence
  end

  # TODO: Deprecate for pattern in Utilities::Nomencalture.htmlize
  # This should never require hitting the database.
  def get_original_combination_html
    return verbatim_name if !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string) && !verbatim_name.nil?
    return  "\"<i>Candidatus</i> #{get_original_combination}\"" if is_candidatus?

    # x = get_original_combination
    # y = cached_original_combination # In a transaction this is not available
    v = @_cached_build_state[:original_combination]

    return nil if v.blank?

    if is_hybrid?
      w = v.split(' ')
      w[-1] = ('×' + w[-1]).gsub('×(', '(×').gsub(') [sic]', ' [sic])').gsub(') (sic)', ' (sic))')
      v = w.join(' ')
    end

    v = v.gsub(') [sic]', ' [sic])').gsub(') (sic)', ' (sic))')

    v = Utilities::Italicize.taxon_name(v) if is_genus_or_species_rank?
    v = '† ' + v  if is_fossil? # This doesn't belong here, it's touching the DB.
    v
  end

  # @return [String]
  #   TODO: does this form of the name contain parens for subgenus?
  #   TODO: don't use this when [nil, name, 'sic'] is expected
  #   TODO: provide a default to gender (but do NOT eliminate param)
  #   TODO: on third thought- eliminate this mess
  #
  def name_with_misspelling(gender)
    if cached_misspelling
      name_in_gender(gender) + ' ' + misspelling_tag
    elsif gender.nil? || rank_string =~ /Genus/
      name
    else
      name_in_gender(gender)
    end
  end

  def misspelling_tag
    if rank_string =~ /Icnp/
      '(sic)'
    else
      '[sic]'
    end
  end

  # @return [String, nil]
  def genderized_name(gender = nil)
    if gender.nil? || is_genus_rank?
      name
    else
      name_in_gender(gender)
    end
  end

  # @return [String, nil]
  #    a monominal, as originally rendered, with parens if subgenus, and '[sic]' (bad!) if misspelled
  def original_name
    n = verbatim_name.nil? ? name_with_misspelling(nil) : verbatim_name
    n = "(#{n})" if n && rank_name == 'subgenus'
    n
  end

  # @param gender, String
  # @return String
  #   then name according to the gender requested, if none, then `name`
  def name_in_gender(gender = nil)
    case gender
    when 'masculine'
      n = masculine_name
    when 'feminine'
      n = feminine_name
    when 'neuter'
      n = neuter_name
    else
      n = nil
    end
    n.presence || name
  end

  private
end
