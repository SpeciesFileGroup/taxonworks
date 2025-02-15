# The names table includes
# * All name strings, even if hanging (= not attached to OTUs/Taxa)
# * It contains strings that may be invalid OR valid
module Export::Coldp::Files::Name

  @skipped_name_ids = []

  def self.skipped_name_ids
    @skipped_name_ids
  end

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
    if !name_remarks_vocab_id.nil? && name.data_attributes.where(controlled_vocabulary_term_id: name_remarks_vocab_id).any?
      name.data_attributes.where(controlled_vocabulary_term_id: name_remarks_vocab_id).pluck(:value).join('|')
    else
      nil
    end
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

        ## TODO: very expensive, consider caching in TN
        # c = taxon_name.taxon_name_classifications_for_statuses.order_by_youngest_source_first.first

        c = TaxonNameClassification.youngest(taxon_name.taxon_name_classifications_for_statuses)

        # We should also infer status from TaxonNameRelationship and be more specific, but if CoL doesn't
        # use NOMEN this won't mean much
        #
        # Note: We supply `nil` when relationship is used here because it is declared in synonym table.
        # Note: This means that the *type* of synonym is lost (e.g. Misspelling)

        c ? c.class::NOMEN_URI : nil
      end
    end
  end

  def self.add_higher_original_name(t, csv, origin_citation, name_remarks_vocab_id, project_members)

    id = t.reified_id
    uninomial = clean_sic({:scientific_name => t.cached_original_combination})[:scientific_name]

    csv << [
      id,                                                                 # ID
      nil,                                                                # basionymID
      uninomial,                                                          # scientificName
      t.original_author_year,                                             # authorship
      t.rank,                                                             # rank
      uninomial,                                                          # uninomial
      nil,                                                                # genus
      nil,                                                                # subgenus (no parens)
      nil,                                                                # species
      nil,                                                                # infraspecificEpithet
      origin_citation&.source_id,                                         # referenceID    |
      origin_citation&.pages,                                             # publishedInPage  | !! All origin citations get added to reference_csv via the main loop, not here
      t.year_of_publication,                                              # publishedInYear  |
      true,                                                               # original
      code_field(t),                                                      # code
      nil,                                                                # status https://api.checklistbank.org/vocab/nomStatus
      nil,                                                                # link (probably TW public or API)
      Export::Coldp.sanitize_remarks(remarks(t, name_remarks_vocab_id)),  # remarks
      Export::Coldp.modified(t[:updated_at]),                             # modified
      Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
    ]
  end

  # Invalid Protonyms are rendered only as their original Combination
  # @param t [Protonym]
  #    only place that var./frm can be handled.
  def self.add_original_combination(t, csv, origin_citation, name_remarks_vocab_id, project_members)
    # TODO: Should [sic] handling be added to the Protonym#original_combination_elements method? Need to discuss with DD and MJY
    e = {}
    
    # TODO: Not sure why, but the data stucture from  t.original_combination_elements seems to be either of the following:
    #   {:genus=>[nil, "Sabacon"], :species=>[nil, "vizcayanus [sic]"]} 
    #   {:genus=>[nil, "Sabacon"], :species=>[nil, "vizcayanus", "[sic]"]}

    t.original_combination_elements.each do |k, v|
      v.delete('[sic]')
      e[k] = v
    end

    epithets = clean_sic({:scientific_name => t.cached_original_combination, :genus => e[:genus]&.last, :subgenus => e[:subgenus]&.last, :species => e[:species]&.last, :subspecies => e[:subspecies]&.last})
    infraspecific_element = t.original_combination_infraspecific_element(t.original_combination_elements, remove_sic: true)

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

    # skip names with "NOT SPECIFIED" elements
    if t.cached_original_combination =~ /NOT SPECIFIED/
      @skipped_name_ids.push(id)
      return
    end

    basionym_id = if !t.valid?
                    id
                  elsif t.has_misspelling_relationship?  # uses cached values now.
                    t.valid_taxon_name.reified_id
                  else
                    id
                  end
 
    # case 1 - original combination difference
    # case 2 - misspelling (same combination)

    uninomial, genus, subgenus, species = nil, nil, nil, nil

    scientific_name = epithets[:scientific_name]
    if rank == :genus
      uninomial = epithets[:genus]
    else
      genus = epithets[:genus]
      subgenus = epithets[:subgenus]&.gsub(/[\)\(]/, '')
      species = epithets[:species]
    end

    csv << [
      id,                                                                 # ID
      basionym_id,                                                        # basionymID
      scientific_name,                                                    # scientificName
      t.original_author_year,                                             # authorship
      rank,                                                               # rank
      uninomial,                                                          # uninomial
      genus,                                                              # genus
      subgenus,                                                           # subgenus (no parens)
      species,                                                            # species
      infraspecific_element ? infraspecific_element.last : nil,           # infraspecificEpithet
      origin_citation&.source_id,                                         # referenceID    |
      origin_citation&.pages,                                             # publishedInPage  | !! All origin citations get added to reference_csv via the main loop, not here
      t.year_of_publication,                                              # publishedInYear  |
      true,                                                               # original
      code_field(t),                                                      # code
      nil,                                                                # status https://api.checklistbank.org/vocab/nomStatus
      nil,                                                                # link (probably TW public or API)
      Export::Coldp.sanitize_remarks(remarks(t, name_remarks_vocab_id)),  # remarks
      Export::Coldp.modified(t[:updated_at]),                             # modified
      Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
    ]
  end

  def self.clean_sic(epithets)
    if epithets.values.any? { |value| value&.include?('[sic]') }
      epithets.transform_values { |value| value&.gsub(/\s*\[sic\]/, '') }
    else
      epithets
    end
  end

  # @params otu [Otu]
  #   the top level OTU
  def self.generate(otu, project_members, reference_csv = nil)
    name_total = 0

    output = {}
    output[:csv] = ::CSV.generate(col_sep: "\t") do |csv|

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
        modified
        modifiedBy
      }

      # We should not be setting this here !!
      project_id = otu.project_id

      name_remarks_vocab_id = Predicate.find_by(
        uri: 'https://github.com/catalogueoflife/coldp#Name.remarks',
        project_id: project_id)&.id

      # TODO: create a base select that covers all fields, to which we add where'joins to isolate sets of names.
      # TODO: All top level queries should add names from SQL without NOT checks
      # TODO: consider a materialized view for COLDP names, refreshed nightly, outside the loop?
      #   we are basically going to need that logic for BORG anyways  
      otu.taxon_name.self_and_descendants.that_is_valid
        .select(:id, :cached)
        .find_each do |name|

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

        # TODO: remove this loopp, using a with to top 
        TaxonName
          .where(cached_valid_taxon_name_id: name.id) # == .historical_taxon_names
          .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", name.cached) # This eliminates Combinations that are identical to the current placement.
          .eager_load(origin_citation: [:source])
          .find_each do |t|

          #  TODO: refactor to a single method, test, then we should only have to check if the name is valid, without relationships?
          # TODO: family-group cached original combinations do not get exported in either Name or Synonym tables
          # exclude duplicate protonyms created for family group relationships
          if !t.is_combination? and t.is_family_rank? # We are already excluding combinationss from above
            if TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm.where(subject_taxon_name: t).any? #  t.taxon_name_relationships.any? {|tnr| tnr.type == 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm'}
              valid = TaxonName.find(t.cached_valid_taxon_name_id)
              if valid.name == t.name  and valid.cached_author = t.cached_author and t.id != valid.id # !! valid.name should never = t.name, by definition?
                next
              end
            end
          end

          origin_citation = t.origin_citation

          original = Export::Coldp.original_field(t) # Protonym, no parens

          basionym_id = t.reified_id unless !t.is_combination? and t.is_family_rank?

          is_genus_species = t.is_genus_or_species_rank?

          # TODO: Subgenus as Genus combination may break this
          is_col_uninomial = !t.is_combination? && ((t.rank == 'genus') || !is_genus_species)

          higher = !t.is_combination? && !is_genus_species

          uninomial, generic_epithet, infrageneric_epithet, specific_epithet, infraspecific_epithet = nil, nil, nil, nil, nil

          if !is_col_uninomial
            elements = t.full_name_hash

            epithets = clean_sic({:scientific_name => t.cached, :genus => elements['genus']&.last, :subgenus => elements['subgenus']&.last, :species => elements['species']&.last, :subspecies => elements['subspecies']&.last})

            name_string = epithets[:scientific_name]
            generic_epithet = epithets[:genus]
            infrageneric_epithet = epithets[:subgenus]
            specific_epithet = epithets[:species]
            infraspecific_epithet = epithets[:subspecies]
          else
            uninomial = name_string = clean_sic({:scientific_name => t.cached})[:scientific_name]
          end

          if t.is_combination?
            rank = t.protonyms_by_rank.keys.last
          else
            rank = t.rank
          end

          # Here we truly want no higher
          if t.cached_original_combination.present? && (!t.is_combination? && is_genus_species && (!t.is_valid? || t.has_alternate_original?))
            name_total += 1
            add_original_combination(t, csv, origin_citation, name_remarks_vocab_id, project_members)
          end

          # Here we add reified ID's for higher taxa in which cached != cached_original_combination (e.g., TaxonName stores both Lamotialnina and Lamotialnini so needs a reified ID)
          if t.cached_original_combination.present? && t.is_family_rank? && t.has_alternate_original? # t.cached != t.cached_original_combination
            add_higher_original_name(t, csv, origin_citation, name_remarks_vocab_id, project_members)
          end

          basionym_id = nil if @skipped_name_ids.include?(basionym_id)

          # Set is: no original combination OR (valid or invalid higher, valid lower, past combinations)
          if t.cached_original_combination.blank? || higher || t.is_valid? || t.is_combination?
            csv << [
              t.id,                                                               # ID
              basionym_id,                                                        # basionymID
              name_string,                                                        # scientificName  # should just be t.cached
              t.cached_author_year,                                               # authorship
              rank,                                                               # rank
              uninomial,                                                          # uninomial   <- if genus here
              generic_epithet,                                                    # genus and below - IIF species or lower
              infrageneric_epithet,                                               # infragenericEpithet
              specific_epithet,                                                   # specificEpithet
              infraspecific_epithet,                                              # infraspecificEpithet
              origin_citation&.source_id,                                         # publishedInID
              origin_citation&.pages,                                             # publishedInPage
              t.year_of_publication,                                              # publishedInYear
              original,                                                           # original
              code_field(t),                                                      # code
              nom_status_field(t),                                                # nomStatus
              nil,                                                                # link (probably TW public or API)
              Export::Coldp.sanitize_remarks(remarks(t, name_remarks_vocab_id)),  # remarks
              Export::Coldp.modified(t[:updated_at]),                             # modified
              Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
            ]
          end

          Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
        end
      end
    end
  end

end
