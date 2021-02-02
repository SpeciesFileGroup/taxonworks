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

  def self.remarks_field(taxon_name)
    Utilities::Strings.nil_squish_strip(taxon_name.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
  end

  # @return String
  def self.authorship_field(taxon_name, original)
    original ? taxon_name.original_author_year : taxon_name.cached_author_year
  end

  # https://api.catalogue.life/vocab/nomStatus
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
  def self.add_original_combination(t, csv)
    e = t.original_combination_elements

    infraspecific_element = t.original_combination_infraspecific_element(e)

    rank = nil
    if infraspecific_element
      infraspecific_element.first
    else
      [:subspecies, :species, :subgenus, :genus].each do |r|
        if e[r]
          rank = r
          break
        end
      end
    end

    genus, subgenus, species = nil, nil, nil

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

    id = t.reified_id

    basionym_id = t.has_misspelling_relationship? ? t.valid_taxon_name.reified_id : id # => t.reified_id
    # case 1 - original combination difference
    # case 2 - misspelling (same combination)

    csv << [
      id,                                                                         # ID
      basionym_id,                                                                # basionymID (can't be invalid
      t.cached_original_combination&.gsub(/\s+\[sic\]/, ''),                       # scientificName # TODO: once cache is fixed remove &. check
      authorship_field(t, true),                                                  # authorship
      rank,                                                                       # rank
      nil,                                                                        # uninomial
      genus,                                                                      # genus
      subgenus,                                                                   # subgenus (no parens) # TODO - optimize to not have to strip these
      species,                                                                    # species
      infraspecific_element ? infraspecific_element.last : nil,                   # infraspecificEpithet
      nil,                                                                        # publishedInID   |
      nil,                                                                        # publishedInPage |-- Decisions is that these add to Synonym table
      nil,                                                                        # publishedInYear |
      true,                                                                       # original
      code_field(t),                                                              # code
      nil,                                                                        # status https://api.catalogue.life/vocab/nomStatus
      nil,                                                                        # link (probably TW public or API)
      remarks_field(t),                                                           # remarks
    ]
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
        publishedInID
        publishedInPage
        publishedInYear
        original
        code
        status
        link
        remarks
      }

      # why we getting double
      #  unique = {}

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
          higher = !t.is_combination? && !t.is_species_rank?

          elements = t.full_name_hash if !higher

          basionym_id = t.reified_id

          name_string = higher ? t.name : t.cached

          if higher || t.is_valid? || t.is_combination?
            csv << [
              t.id,                                               # ID
              basionym_id,                                        # basionymID
              name_string,                                        # scientificName
              t.cached_author_year,                               # authorship
              t.rank,                                             # rank
              (higher ? name_string : nil),                       # uninomial
              (higher ? nil : elements['genus']&.last),           # genus and below - IIF species or lower
              (higher ? nil : elements['subgenus']&.last),        # infragenericEpithet
              (higher ? nil : elements['species']&.last),         # specificEpithet
              (higher ? nil : elements['subspecies']&.last),      # infraspecificEpithet
              origin_citation&.source_id,                         # publishedInID
              origin_citation&.pages,                             # publishedInPage
              t.year_of_publication,                              # publishedInYear
              original,                                           # original
              code_field(t),                                      # code
              nom_status_field(t),                                # nomStatus
              nil,                                                # link (probably TW public or API)
              remarks_field(t),                                   # remarks
            ]
          end

          if (!higher && !t.is_combination? && (!t.is_valid? || t.has_alternate_original?)) # TODO: Confirm unnecessary: && unique[basionym_id].nil?
            # unique[basionym_id] = true
            name_total += 1
            add_original_combination(t, csv)
          end

          Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv) if reference_csv && origin_citation
        end
      end

      puts Rainbow("----------TOTAL: #{name_total}------").red.bold
    end
  end

end
