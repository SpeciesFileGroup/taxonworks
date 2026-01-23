#
# Methods for gathering elements for use in constructing names from the graph of data.
#
module Protonym::Format
  extend ActiveSupport::Concern

  included do
    attr_accessor :original_combination_elements

    # @return [Hash]
    #
    # {
    #  genus: ["", 'Aus' ],
    #  ...
    #  form: ['frm', 'aus']
    # }
    #
    def original_combination_elements # ?? Need reload off mode for write
      return @original_combination_elements unless @original_combination_elements.nil?

      elements = { }
      return elements if rank.blank?

      this_rank = rank.to_sym

      # Why this?
      #   We need to apply gender to "internal" names for original combinations, everything
      #   but the last name. If we have subspecies, the species name should be used not in the original form,
      #   but the form correlated with the present genus gender

      # Protonym.joins(:original_combination_relationships)
      #     .first.original_combination_protonyms
      #     .order(Arel.sql("ARRAY_POSITION(ARRAY[#{ORIGINAL_COMBINATION_RANKS.collect{|a| "'" + a + "'"}.join(',')}], taxon_name_relationships.type)"))

      # order the relationships
      r = original_combination_relationships
        .eager_load(:subject_taxon_name)
        .sort{|a,b| ORIGINAL_COMBINATION_RANKS.values.index(a.type) <=> ORIGINAL_COMBINATION_RANKS.values.index(b.type) }

      # This is using the memoized version, but needs to always reload at this point. If we can work this
      # into an early call then we can re-use the relationship load.
      #
      # r = related_relationships(true).select{|r| r.type.match('Orig')}  # =~ /Orig/} #  original_combination_relationships
      #  .sort{|a,b| ORIGINAL_COMBINATION_RANKS.values.index(a.type) <=> ORIGINAL_COMBINATION_RANKS.values.index(b.type) }

      return {} if r.blank?

      genus = r.select{|r| r.type =~ /Genus/}.first&.subject_taxon_name # This is the original genus

      gender = genus&.cached_gender

      # Apply gender to everything ***but the last***
      total = r.count - 1

      r.each_with_index do |j, i|
        if j.type =~ /enus/ || i == total
          g = nil
        else
          g = gender
        end

        elements.merge! j.combination_name(g) # this is like '{genus: [nil, 'Aus']}
      end

      # TODO: Confirm specific tests exist for this block.

      # Plug in self if self referencing OriginalCombination is not present (we do not require it).
      if r.last.subject_taxon_name.lowest_rank_coordinated_taxon.id != lowest_rank_coordinated_taxon.id # hella expensive

        if elements[this_rank].nil?
          n = verbatim_name.nil? ? name : verbatim_name
          n = "(#{n})" if n && rank_name == 'subgenus'
          v = [nil, n] # It is never genderized
          v.push misspelling_tag if cached_misspelling
          elements[this_rank] = v
        end
      end

      if elements.any?
        if !elements[:genus] && !not_binominal?
          if genus
            elements[:genus] = [nil, "[#{genus&.name}]"] # !? why
          else
            elements[:genus] = [nil, '[GENUS NOT SPECIFIED]']
          end
        end
        # If there is no :species, but some species group, add element
        elements[:species] = [nil, '[SPECIES NOT SPECIFIED]'] if !elements[:species] && ( [:subspecies, :variety, :form] & elements.keys ).size > 0
      end

      @original_combination_elements = elements
    end

  end

  module ClassMethods

    # CAREFUL - the last name doesn't get genderized in rendering !!!
    # TODO: consider an 'include_cached_misspelling' Boolean to extend result to include `cached_misspelling`
    def original_combinations_flattened
      s = []
      abbreviation_cutoff = 'subspecies'
      abbreviate = false

      ::ORIGINAL_COMBINATION_RANKS.each do |rank, t|
        s.push "MAX(original_combination_protonyms_taxon_names.name) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}"

        # See unused original_combination_flat
        s.push "MAX(original_combination_protonyms_taxon_names.cached_gender) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}_gender"

        s.push "MAX(original_combination_protonyms_taxon_names.neuter_name) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}_neuter"
        s.push "MAX(original_combination_protonyms_taxon_names.masculine_name) FILTER (WHERE taxon_name_relationships.type  =  '#{t}') AS #{rank}_masculine"
        s.push "MAX(original_combination_protonyms_taxon_names.feminine_name) FILTER (WHERE taxon_name_relationships.type  = '#{t}') AS #{rank}_feminine"

        if abbreviate
          s.push "MAX(original_combination_protonyms_taxon_names.rank_class) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}_rank_class"
        end

        abbreviate = true if rank == abbreviation_cutoff

      end

      s.push 'taxon_names.id, taxon_names.name, taxon_names.cached, taxon_names.cached_original_combination, taxon_names.cached_author_year, taxon_names.cached_nomenclature_date,
        taxon_names.rank_class, taxon_names.cached_misspelling, taxon_names.cached_is_valid, taxon_names.cached_valid_taxon_name_id,
        taxon_names.updated_by_id, taxon_names.updated_at, sources.id source_id, citations.pages'

      sel = s.join(',')

      Protonym.joins(:source, :original_combination_protonyms)
        .select(sel)
        .group('taxon_names.id, sources.id, citations.pages')
    end

    # @return [Hash]
    #   Similar pattern to full_name hash
    # !! Does not include '[sic]'
    # !! Does not include 'NOT SPECIFIED' ranks.
    #
    # Intent is to chain with scopes within COLDP export.
    #
    # If this becomes more broadly useful consider optional `sic` inclusion.
    #
    def original_combination_full_name_hash_from_flat(row)
      data = {}
      gender = row['genus_gender']

      # ranks are symbols here, elsewhere strings.
      # loop protonyms
      ORIGINAL_COMBINATION_RANKS.each do |rank, type|
        next if row[rank].nil?

        last = if row[rank]
          row[:cached_original_combination] =~ /#{row[rank]}\z/ ? true : false
        else
          false
        end

        # Do not genderize the last name
        name_target = (gender.nil? || last) ? rank : (rank.to_s + '_' + gender).to_sym

        # TODO: add verbatim to row(?)
        name = row[name_target] || row[rank] || row[(rank.to_s + '_' + 'verbatim')]

        v = [nil, name]

        unless ['genus', 'subgenus', 'species', 'subspecies'].include?(rank.to_s)
          v[0] = row[rank.to_s + ' ' + 'rank_class']
        end

        data[rank.to_s] = v

        break if last
      end
      data
    end

  end # End Class methods

  def original_combination_flat
    s = []
    ::ORIGINAL_COMBINATION_RANKS.each do |rank, t|
      s.push "MAX(name) FILTER (WHERE rt = '#{t}') AS #{rank},
              MAX(cached_gender) FILTER (WHERE rt = '#{t}') AS #{rank}_gender,
              MAX(neuter_name) FILTER (WHERE rt = '#{t}') AS #{rank}_neuter,
              MAX(masculine_name) FILTER (WHERE rt = '#{t}') AS #{rank}_masculine,
              MAX(feminine_name) FILTER (WHERE rt = '#{t}') AS #{rank}_feminine"
    end

    a = Protonym
      .joins(:original_combination_relationships)
      .where(taxon_name_relationships: {
        object_taxon_name_id: id
      }).select(:id, :name, :cached_gender, :neuter_name, :masculine_name, :feminine_name, 'taxon_name_relationships.type as rt')

    Protonym.with(filtered: a).select(s.join(',')).from('filtered').unscope(:where)[0]
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
    if is_candidatus?
      return cached_html if get_original_combination.nil?
      return  "\"<i>Candidatus</i> #{get_original_combination}\""
    end
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

  # @return an Array
  #   [<rank abbreiviation>, name, <misspelling tag>]]]]]
  #
  # !! No parens shoould be added here
  def genderized_elements(gender)
    n = genderized_name(gender)

    if n.blank?
      n = verbatim_name.nil? ? name : verbatim_name
    end

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
