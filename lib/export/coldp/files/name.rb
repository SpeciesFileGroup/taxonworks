

# The names table includes
# * All names strings, even if hanging (= not attached to OTUs/Taxa)
module Export::Coldp::Files::Name

  def self.code_field(taxon_name)
    case taxon_name.nomenclatural_code
    when :iczn
      'ICZN'
    when :icn
      'ICN'
    when :icnp
      'ICNP'
    when :icvcn
      'ICVCN'
    end
  end

  def self.remarks(name, name_remarks_vocab_id)
    if name.data_attributes.where(controlled_vocabulary_term_id: name_remarks_vocab_id).any?
      name.data_attributes.where(controlled_vocabulary_term_id: name_remarks_vocab_id).pluck(:value).join('|')
    else
      nil
    end
  end

  # @return String
  def self.authorship_field(taxon_name, original)
    original ? taxon_name.original_author_year : taxon_name.cached_author_year
  end

  # https://api.checklistbank.org/vocab/nomStatus
  # @return [String, nil]
  # @params taxon_name [TaxonName]
  #   any TaxonName
  def self.nom_status_field(taxon_name)
    case taxon_name.type
    when 'Combination'
      nil # This is *not* 'chresonym' sensu CoL (which is this: [correct: 'Aus bus Smith 1920', chresonym: 'Aus bus Jones 1922'])
    else
      if taxon_name.is_valid?
        ::TaxonName::NOMEN_VALID[taxon_name.nomenclatural_code]
      else
        c = taxon_name.taxon_name_classifications_for_statuses.order_by_youngest_source_first.first

        # We should also infer status from TaxonNameRelationship and be more specific, but if CoL doesn't
        # use NOMEN this won't mean much
        #
        # Note: We supply `nil` when relationship is used here because it is declared in synonym table.
        # Note: This means that the *type* of synonym is lost (e.g. Misspelling)

        c ? c.class::NOMEN_URI : nil
      end
    end
  end

  # Invalid Protonyms are rendered only as their original Combination
  # @param t [Protonym]
  #    only place that var./frm can be handled.
  def self.add_original_combination(t, csv, origin_citation, name_remarks_vocab_id)
    e = t.original_combination_elements

    infraspecific_element = t.original_combination_infraspecific_element(e)

    rank = nil
    if infraspecific_element
      rank = infraspecific_element.first
      rank = 'forma' if rank == 'form' # CoL preferred string
    else
      [:subspecies, :species, :subgenus, :genus].each do |r|
        if e[r]
          rank = r
          break
        end
      end
    end

    id = t.reified_id
    basionym_id = t.has_misspelling_relationship? ? t.valid_taxon_name.reified_id : id # => t.reified_id
    # case 1 - original combination difference
    # case 2 - misspelling (same combination)

    genus, subgenus, species = nil, nil, nil

    uninomial = nil

    if rank == :genus
      uninomial = e[:genus][1]

    else
      if e[:genus]
        if e[:genus][1] =~ /NOT SPECIFIED/
          genus = nil
        else
          genus = e[:genus][1]
        end
      end

      if e[:subgenus]
        if e[:subgenus][1] =~ /NOT SPECIFIED/
          subgenus = nil
        else
          subgenus = e[:subgenus][1]&.gsub(/[\)\(]/, '')
        end
      end

      if e[:species]
        if e[:species][1] =~ /NOT SPECIFIED/
          species = nil
        else
          species = e[:species][1]
        end
      end

    end

    csv << [
      id,                                                        # ID
      basionym_id,                                               # basionymID
      clean_sic(t.cached_original_combination),                  # scientificName
      authorship_field(t, true),                                 # authorship
      rank,                                                      # rank
      uninomial,                                                 # uninomial
      genus,                                                     # genus
      subgenus,                                                  # subgenus (no parens)
      species,                                                   # species
      infraspecific_element ? infraspecific_element.last : nil,  # infraspecificEpithet
      origin_citation&.source_id,                                # referenceID    |
      origin_citation&.pages,                                    # publishedInPage  | !! All origin citations get added to reference_csv via the main loop, not here
      t.year_of_publication,                                     # publishedInYear  |
      true,                                                      # original
      code_field(t),                                             # code
      nil,                                                       # status https://api.checklistbank.org/vocab/nomStatus
      nil,                                                       # link (probably TW public or API)
      remarks(t, name_remarks_vocab_id),                         # remarks
    ]
  end

  def self.clean_sic(name)
    name&.gsub(/\s+\[sic\]/, '') # TODO: remove `&` once cached_original_combination is re-indexed
  end

  # @params otu [Otu]
  #   the top level OTU
  def self.generate(otu, reference_csv = nil)
     name_total = 0
    CSV.generate(col_sep: "\t") do |csv|
      csv << %w{
        ID
        basionymID
        scientificName
        authorship
        rank
        uninomial
        genus
        infragenericEpithet
        specificEpithet
        infraspecificEpithet
        referenceID
        publishedInPage
        publishedInYear
        original
        code
        status
        link
        remarks
      }

      Current.project_id = otu.project_id
      name_remarks_vocab_id = Predicate.find_by(uri: 'https://github.com/catalogueoflife/coldp#Name.remarks',
                                                project_id: Current.project_id)&.id

      otu.taxon_name.self_and_descendants.that_is_valid
        .pluck(:id, :cached)
        .each do |name|

        # TODO: handle > quadranomial names (e.g. super species like `Bus (Dus aus aus) aus eus var. fus`
        # Proposal is to exclude names of a specific ranks see taxon.rb
        #
        # Need the next highest valid parent not in this list!!
        # %w{
        #   NomenclaturalRank::Iczn::SpeciesGroup::Supersuperspecies
        #   NomenclaturalRank::Iczn::SpeciesGroup::Superspecies
        # }
        #
        # infragenericEpithet needs to handle subsection (NomenclaturalRank::Icn::GenusGroup::Subsection)

        name_total += 1

        TaxonName
          .where(cached_valid_taxon_name_id: name[0]) # == .historical_taxon_names
          .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", name[1]) # This eliminates Combinations that are identical to the current placement.
          .find_each do |t|

          origin_citation = t.origin_citation

          original = Export::Coldp.original_field(t) # Protonym, no parens

          basionym_id = t.reified_id

          is_genus_species = t.is_genus_or_species_rank?

          # TODO: Subgenus as Genus combination may break this
          is_col_uninomial = !t.is_combination? && ((t.rank == 'genus') || !is_genus_species)

          higher = !t.is_combination? && !is_genus_species

          # TODO: consider faster ways to check for misspellings
          name_string = clean_sic(t.cached) # if higher and misspelling, then it's in name too

          uninomial = nil
          generic_epithet, infrageneric_epithet, specific_epithet, infraspecific_epithet = nil, nil, nil, nil

          if !is_col_uninomial
            elements = t.full_name_hash

            generic_epithet = clean_sic(elements['genus']&.last)
            infrageneric_epithet = clean_sic(elements['subgenus']&.last)
            specific_epithet = clean_sic(elements['species']&.last)
            infraspecific_epithet = clean_sic(elements['subspecies']&.last)
          else
            uninomial = name_string
          end

          # TODO: Combinations don't have rank BUT CoL importer can interpret, so we're OK here for now
          rank = t.rank

          # Set is: no original combination OR (valid or invalid higher, valid lower, past combinations)
          if t.cached_original_combination.blank? || higher || t.is_valid? || t.is_combination?
            csv << [
              t.id,                                     # ID
              basionym_id,                              # basionymID
              name_string,                              # scientificName  # should just be t.cached
              t.cached_author_year,                     # authorship
              rank,                                     # rank
              uninomial,                                # uninomial   <- if genus here
              generic_epithet,                          # genus and below - IIF species or lower
              infrageneric_epithet,                     # infragenericEpithet
              specific_epithet,                         # specificEpithet
              infraspecific_epithet,                    # infraspecificEpithet
              origin_citation&.source_id,               # publishedInID
              origin_citation&.pages,                   # publishedInPage
              t.year_of_publication,                    # publishedInYear
              original,                                 # original
              code_field(t),                            # code
              nom_status_field(t),                      # nomStatus
              nil,                                      # link (probably TW public or API)
              remarks(t, name_remarks_vocab_id),        # remarks
            ]
          end

          # Here we truly want no higher
          if !t.cached_original_combination.blank? && (is_genus_species && !t.is_combination? && (!t.is_valid? || t.has_alternate_original?))
            name_total += 1
            add_original_combination(t, csv, origin_citation, name_remarks_vocab_id)
          end

          Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv) if reference_csv && origin_citation
        end
      end
    end
  end

end
