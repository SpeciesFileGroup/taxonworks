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

  def self.combination_core(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id, :cached)
    b = ::Combination.with(scope: a)
      .joins('JOIN scope on scope.id = taxon_names.cached_valid_taxon_name_id')
      .where.not("taxon_names.cached = scope.cached")


    b =  b.select(
      'taxon_names.id, taxon_names.cached,

    MAX(CASE WHEN tnr.type LIKE \'%::Genus\' THEN parent.name END) AS genus,
    MAX(CASE WHEN tnr.type LIKE \'%::Subgenus\' THEN parent.name END) AS subgenus,
    MAX(CASE WHEN tnr.type LIKE \'%::Species\' THEN parent.name END) AS species,
    MAX(CASE WHEN tnr.type LIKE \'%::Subspecies\' OR tnr.type LIKE \'%::Variety\' OR parent.type LIKE \'%::Form\' THEN parent.name END) AS infraspecies'
    ).joins('LEFT JOIN taxon_name_relationships tnr ON taxon_names.id = tnr.object_taxon_name_id')
      .joins('LEFT JOIN taxon_names AS parent ON parent.id = tnr.subject_taxon_name_id')
      .group('taxon_names.id')

    # .and(TaxonName.where.not("taxon_names.rank_class like '%::Iczn::Family%' AND taxon_names.cached_is_valid = FALSE")) # This eliminates Combinations that are identical to the current placement.
    # .eager_load(origin_citation: [:source])
  end

  # Refactored serial appraoch
  #   valid names
  #   invalid names
  #   something about uninomials
  #   somethign about combinations
  #   somethign about original combinations

  # The goal here is to create a single scoped TaxonName
  # returning query that represents the superset of
  # names condisered valid by TW
  def self.core_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id, :cached)
    b = ::Protonym.is_species_or_genus_group.with(valid_scope: a)
      .joins('JOIN valid_scope on valid_scope.id = taxon_names.cached_valid_taxon_name_id')  #.where(cached_valid_taxon_name_id: name.id) # == .historical_taxon_names
      .and(TaxonName.where.not("taxon_names.rank_class like '%::Iczn::Family%' AND taxon_names.cached_is_valid = FALSE")) # This eliminates Combinations that are identical to the current placement.
      .eager_load(origin_citation: [:source])

    b =  b.select(
      'taxon_names.id,
      MAX(CASE WHEN parent.rank_class LIKE \'%::Genus\' THEN parent.name END) AS genus,
      MAX(CASE WHEN parent.rank_class LIKE \'%::Subgenus\' THEN parent.name END) AS subgenus,
      MAX(CASE WHEN parent.rank_class LIKE \'%::Species\' THEN parent.name END) AS species,
      MAX(CASE WHEN parent.rank_class LIKE \'%::Subspecies\' OR parent.rank_class LIKE \'%::Variety\' OR parent.rank_class LIKE \'%::Form\' THEN parent.name END) AS infraspecies'
    ).joins('INNER JOIN taxon_name_hierarchies ON taxon_names.id = taxon_name_hierarchies.descendant_id')
      .joins('LEFT JOIN taxon_names AS parent ON parent.id = taxon_name_hierarchies.ancestor_id')
      .group('taxon_names.id')

    c = ::TaxonName.with(n: b)
      .joins('JOIN n on n.id = taxon_names.id')
      .eager_load(origin_citation: [:source])
      .select('taxon_names.*, n.genus, n.subgenus, n.species, n.infraspecies')
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
        project_id:)&.id


        add_core_names(otu, csv, name_remarks_vocab_id, project_members, reference_csv)
        # add_higher(otu, csv, name_remarks_vocab_id, project_members)
        # add_combinations(otu, csv, name_remarks_vocab_id, project_members)
        # add_original_combinations(otu, csv, name_remarks_vocab_id, project_members)

    end
  end

  def self.add_core_names(otu, csv, name_remarks_vocab_id, project_members, reference_csv)

    core_names(otu).find_each do |t|

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

      # name_total += 1

      # TODO: remove this loopp, using a with to top
      #   TaxonName
      #     .where(cached_valid_taxon_name_id: name.id) # == .historical_taxon_names
      #     .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", name.cached) # This eliminates Combinations that are identical to the current placement.
      #     .eager_load(origin_citation: [:source])
      #     .find_each do |t|

      # TODO: refactor to a single method, test, then we should only have to check if the name is valid, without relationships?
      # TODO: family-group cached original combinations do not get exported in either Name or Synonym tables
      # exclude duplicate protonyms created for family group relationships
      #    if t.is_family_rank? # '%::Iczn::Family%' We are already excluding combinationss from above
      #      if TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm.where(subject_taxon_name: t).any? #  t.taxon_name_relationships.any? {|tnr| tnr.type == 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm'}
      #        valid = TaxonName.find(t.cached_valid_taxon_name_id)
      #        if valid.name == t.name and valid.cached_author = t.cached_author and t.id != valid.id # !! valid.name should never = t.name, by definition?
      #          next
      #        end
      #      end
      #    end

      #   if !t.is_combination? and t.is_family_rank? # We are already excluding combinationss from above
      #     if TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm.where(subject_taxon_name: t).any? #  t.taxon_name_relationships.any? {|tnr| tnr.type == 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm'}
      #       valid = TaxonName.find(t.cached_valid_taxon_name_id)
      #       if valid.name == t.name  and valid.cached_author = t.cached_author and t.id != valid.id # !! valid.name should never = t.name, by definition?
      #         next
      #       end
      #     end
      #   end

      origin_citation = t.origin_citation

      basionym_id = t.reified_id

      # Not combinations, not genus by itself, not genus species names
      is_col_uninomial = t.rank == 'genus' ? true : false

      uninomial, generic_epithet, infrageneric_epithet, specific_epithet, infraspecific_epithet = nil, nil, nil, nil, nil

      if !is_col_uninomial
        # TODO: eliminate, or further minimize calls to full_name hash (15ms?)
        #  - write a method that limits to genus group names and below
        # elements = t.full_name_hash
        #
        name_string = (t.cached =~ /[sic]/) ?
          t.cached.gsub(/\s*\[sic\]/, '') :
          t.cached
        generic_epithet = t.genus
        infrageneric_epithet = t.subgenus
        specific_epithet =  t.species
        infraspecific_epithet = t.infraspecies
      else
        uninomial = name_string = clean_sic({:scientific_name => t.cached})[:scientific_name]
      end

      rank = t.rank

      # Here we truly want no higher
      if t.cached_original_combination.present? # && (!t.is_combination? && is_genus_species && (!t.is_valid? || t.has_alternate_original?))
        # name_total += 1
        #  add_original_combination(t, csv, origin_citation, name_remarks_vocab_id, project_members)
      end

      # # Here we add reified ID's for higher taxa in which cached != cached_original_combination (e.g., TaxonName stores both Lamotialnina and Lamotialnini so needs a reified ID)
      # if t.cached_original_combination.present? && t.is_family_rank? && t.has_alternate_original? # t.cached != t.cached_original_combination
      #   add_higher_original_name(t, csv, origin_citation, name_remarks_vocab_id, project_members)
      # end

      basionym_id = nil if @skipped_name_ids.include?(basionym_id)

      # Set is: no original combination OR (valid or invalid higher, valid lower, past combinations)
      #    if t.cached_original_combination.blank? || higher || t.is_valid? || t.is_combination?
      csv << [
        t.id,                                                               # ID
        basionym_id,                                                        # basionymID
        name_string,                                                        # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        rank,                                                               # rank
        uninomial,                                                          # uninomial   <- if genus here
        generic_epithet,                                                    # genus and below - IIF species or lower
        infrageneric_epithet,                                               # infragenericEpithet (subgenus)
        specific_epithet,                                                   # specificEpithet
        infraspecific_epithet,                                              # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.year_of_publication,                                              # publishedInYear
        code_field(t),                                                      # code
        nom_status_field(t),                                                # nomStatus
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(remarks(t, name_remarks_vocab_id)),  # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]
      #    end

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  def add_name(
    id: nil,
    basionym_id: nil,
    scientific_name: nil,
    authorship:

  )
  end

  NAME_FIELDS = [ 
    :id,                    #   t.id,                                                            
    :basionymID,            #   basionym_id,                                                     
    :scientificName,        #        name_string, # should just be t.cached                                                       
    :authorship,            #        t.cached_author_year,                                              
    :rank,                  #        rank,                                                              
    :uninomial,             #        uninomial,  <- if genus here                                   
    :genus,                 #        generic_epithet,  and below - IIF species or lower                                                  
    :infragenericEpithet,   #        infrageneric_epithet,   (subgenus)                                                
    :specificEpithet,       #        specific_epithet,                                                  
    :infraspecificEpithet,  #        infraspecific_epithet,                                             
    :publishedInID,         #        origin_citation&.source_id,                                        
    :publishedInPage,       #        origin_citation&.pages,                                            
    :publishedInYear,       #        t.year_of_publication,                                             
    :code,                  #        code_field(t),                                                     
    :nomStatus,             #        nom_status_field(t),                                               
    :link,                  #        nil,  (probably TW public or API)                                                              
    :remarks,               #        Export::Coldp.sanitize_remarks(remarks(t, name_remarks_vocab_id)), 
    :modified,              #        Export::Coldp.modified(t[:updated_at]),                            
    :modifiedBy,            #        Export::Coldp.modified_by(t[:updated_by_id], project_members)      
  ]


end
