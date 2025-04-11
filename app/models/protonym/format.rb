# Methods for constructing names from the graph of data.
module Protonym::Format
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  #
  # This method covers scientific name, gathering all string
  # elements, including '[sic]' and pointing to them
  # by rank.
  #
  # @!return [ { rank => [prefix, name] } ]
  #    for ALL names
  #
  # @taxon_name.full_name_hash # =>
  #      { "family' => 'Gidae',
  #        "genus" => [nil, "Aus"],  # Note Array!
  #        "subgenus" => [nil, "Aus"],
  #        "section" => ["sect.", "Aus"],
  #        "series" => ["ser.", "Aus"],
  #        "species" => [nil, "aaa", '[sic]'],
  #        "subspecies" => [nil, "bbb"],
  #        "variety" => ["var.", "ccc"]}
  #
  def full_name_hash
    gender = nil
    data = {}

    # Faster to sort in memory.
    r = TaxonName.rank_order(
      self_and_ancestors.unscope(:order)
    )

    # In the first pass we build out the known vectors
    r.each do |i|
      rank = i.rank

      # Sort order is critical, we need to hit genus before
      # species name to set a gender constant.
      gender = i.cached_gender if rank == 'genus'

      if i.is_genus_or_species_rank?
        if ['genus', 'subgenus', 'species', 'subspecies'].include?(rank) && rank_string =~ /Iczn/
          data[rank] = i.genderized_elements(gender)
        elsif ['genus', 'subgenus', 'species'].include?(rank)
          data[rank] = i.genderized_elements(gender)
        else
          v = i.genderized_elements(gender)
          v[0] = i.rank_class.abbreviation
          data[rank] = v
        end
      else
        data[rank] = i.name
      end
    end

    # In the second pass we populate gaps where we can infer them,
    # for rendering purposes.
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
    # TODO: eliminate these for full_name_hash
    return [name, (cached_misspelling? ? misspelling_tag : nil)].compact.join(' ') if !is_genus_or_species_rank?
    return name if rank_class.to_s =~ /Icvcn/

    # Technically we don't always want/need full_name_hash, as it gives us
    # all ancestors.
    ::Utilities::Nomenclature.full_name(
      full_name_hash,
      rank: rank_name,
      non_binomial: not_binominal?
    )
  end

  def get_original_combination
    return verbatim_name if !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string) && !verbatim_name.nil?
    e = original_combination_elements
    return nil if e.none?

    # TODO: try to catch this before we hit it here.
    # In ICVCN the species name is "Potato spindle tuber viroid", the genus name is only used for classification
    return e[:species][1] if rank_class.to_s =~ /Icvcn/

    # Order the results.
    s = TaxonName::COMBINATION_ELEMENTS.collect{|k| e[k]}.flatten.compact.join(' ')
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

  # @return a vector
  #   nil, name, [sic]
  def genderized_elements(gender)
    n = genderized_name(gender)

    if n.blank?
      n = verbatim_name.nil? ? name : verbatim_name
    end

    #  n = "(#{n})" if n && rank_name == 'subgenus'
    v = [nil, n]
    v.push misspelling_tag if cached_misspelling
    v
  end

  # @return [String, nil]
  def genderized_name(gender = nil)
    if gender.nil? || is_genus_rank?
      name
    else
      name_in_gender(gender)
    end
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

  def misspelling_tag
    if rank_string =~ /Icnp/
      '(sic)'
    else
      '[sic]'
    end
  end

end
