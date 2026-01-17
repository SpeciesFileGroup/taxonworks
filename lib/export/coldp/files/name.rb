# The names table includes
# * All name strings, even if hanging (= not attached to OTUs/Taxa)
# * It contains strings that may be invalid or valid
#
# Future considerations
#   - see bottom, should we parameterize a CSV row add, is it performat?, it
#   would let us DRY all csv << , but it's also not dry to parameterize.
#   Probably OK as is.
#
# TODO:
#  - [ ] refactor ref additions so that they happen at the aggregate level
#  - [ ] resolve the `.length` issue, what the heck is that needed for [see comment from Tom]
#
module Export::Coldp::Files::Name

  #  TODO: Not implemented, resolve
  # and re-implement if needed
  @skipped_name_ids = []

  MANIFEST = [
    :valid_higher_names,
    :valid_family_names,
    :core_names,
    :combination_names, # combinations
    # :verbatim_combination_names,  - *  can we see name is not found in cached ?! *
    # :historical_combination_names, # historical_combinations
    :original_combination_names, # original_combinations
    :invalid_family_and_higher_names,
    :invalid_core_names,
    :invalid_original_combination_names,
  ]

  def self.skipped_name_ids
    @skipped_name_ids
  end

  def self.code_field(rank_class)
    return 'ICZN' if rank_class =~ /Iczn/
    return 'ICNP' if rank_class =~ /Icnp/
    return 'ICVCN' if rank_class =~ /Icvcn/
    return 'ICN' if rank_class =~ /Icn/
    nil
  end

  def self.taxon_name_classification_status(scope)
    c = TaxonNameClassification.with(invalid_names: scope.select('taxon_names.id invalid_id'))
      .joins('JOIN invalid_names ON invalid_names.invalid_id = taxon_name_classifications.taxon_name_id')
      .joins("LEFT JOIN citations c on c.citation_object_id = taxon_name_classifications.id and c.citation_object_type = 'TaxonNameClassification'")
      .joins('LEFT JOIN sources s on s.id = c.source_id')
      .select('taxon_name_classifications.taxon_name_id, s.cached_nomenclature_date,
              MAX(taxon_name_classifications.type) AS type,
              MAX(s.cached_nomenclature_date) as date')
      .group('taxon_name_classifications.taxon_name_id, s.cached_nomenclature_date, taxon_name_classifications.type')
      .order('taxon_name_classifications.taxon_name_id, s.cached_nomenclature_date')

    ApplicationRecord.connection.execute(c.to_sql).to_a
  end

  def self.taxon_name_relationship_status(scope)
    c = TaxonNameRelationship.with(invalid_names: scope.select('taxon_names.id invalid_id'))
      .joins('JOIN invalid_names ON invalid_names.invalid_id = taxon_name_relationships.subject_taxon_name_id')
      .joins("LEFT JOIN citations c on c.citation_object_id = taxon_name_relationships.id and c.citation_object_type = 'TaxonNameClassification'")
      .joins('LEFT JOIN sources s on s.id = c.source_id')
      .where('taxon_name_relationships.object_taxon_name_id = invalid_names.cached_valid_taxon_name_id')
      .where(taxon_name_relationships: {type: TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM})
      .select('taxon_name_relationships.subject_taxon_name_id, s.cached_nomenclature_date,
              MAX(taxon_name_relationships.type) AS type,
              MAX(s.cached_nomenclature_date) as date')
      .group('taxon_name_relationships.subject_taxon_name_id, s.cached_nomenclature_date, taxon_name_relationships.type')
      .order('taxon_name_relationships.subject_taxon_name_id, s.cached_nomenclature_date')

    ApplicationRecord.connection.execute(c.to_sql).to_a
  end

  # Core names are:
  #   - valid
  #   - genus or species group
  #   - Protonyms
  def self.core_names(otu)

    # TODO: adding .that_is_valid increases names, why? Are we hitting duplicates?
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    # b sets up the query that aggregates the different ranks in one row
    b = ::Protonym.is_species_or_genus_group.with(valid_scope: a)
      .where(cached_is_valid: true)
      .joins('JOIN valid_scope on valid_scope.id = taxon_names.cached_valid_taxon_name_id')

    select = 'taxon_names.id,'
    select << ::NomenclaturalRank.rank_expansion_sql(ranks: %w{genus subgenus species}, nomenclatural_code: otu.taxon_name.nomenclatural_code)

    # We group some ranks here
    # TODO: This doesn't likely actually work in the case of subspecies + <some other rank> ?
    select << ", MAX(CASE WHEN parent.rank_class LIKE \'%::Subspecies\' OR parent.rank_class LIKE \'%::Variety\' OR parent.rank_class LIKE \'%::Form\' THEN parent.name END) AS infraspecies"

    b = b.select(select)
      .joins('INNER JOIN taxon_name_hierarchies ON taxon_names.id = taxon_name_hierarchies.descendant_id')
      .joins('LEFT JOIN taxon_names AS parent ON parent.id = taxon_name_hierarchies.ancestor_id')
      .group('taxon_names.id')


    c = ::TaxonName.with(n: b)
      .joins('JOIN n on n.id = taxon_names.id')
      .where(cached_is_valid: true)
      .eager_load(origin_citation: [:source])
      .select('taxon_names.*, n.genus, n.subgenus, n.species, n.infraspecies, n.genus_gender, n.species_masculine_name, n.species_neuter_name, n.species_feminine_name')
  end

  def self.invalid_core_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    b = ::Protonym
      .with(valid_scope: a)
      .joins('JOIN valid_scope on valid_scope.id = taxon_names.cached_valid_taxon_name_id')
      .is_species_or_genus_group
      .where(cached_is_valid: false)
      .where('((taxon_names.cached = taxon_names.cached_original_combination) OR (taxon_names.cached_original_combination IS NULL))')
      .and(TaxonName.where.not("taxon_names.rank_class like '%::Iczn::Family%' AND taxon_names.cached_is_valid = FALSE"))

    select = 'taxon_names.id,'
    select << ::NomenclaturalRank.rank_expansion_sql(ranks: %w{genus subgenus species}, nomenclatural_code: otu.taxon_name.nomenclatural_code)

    # We group some ranks here
    # TODO: This doesn't likely actually work in the case of subspecies + <some other rank> ?
    select << ", MAX(CASE WHEN parent.rank_class LIKE \'%::Subspecies\' OR parent.rank_class LIKE \'%::Variety\' OR parent.rank_class LIKE \'%::Form\' THEN parent.name END) AS infraspecies"

    b = b

    b = b.select(select)
      .joins('INNER JOIN taxon_name_hierarchies ON taxon_names.id = taxon_name_hierarchies.descendant_id')
      .joins('LEFT JOIN taxon_names AS parent ON parent.id = taxon_name_hierarchies.ancestor_id')
      .group('taxon_names.id')
      .eager_load(origin_citation: [:source])

    c = ::TaxonName.with(n: b)
      .joins('JOIN n on n.id = taxon_names.id')
      .where(cached_is_valid: false) # redundant
      .eager_load(origin_citation: [:source])
      .select('taxon_names.*, n.genus, n.subgenus, n.species, n.infraspecies')
  end

  # @params otu [Otu]
  #   the top level OTU
  def self.generate(otu, project_members, reference_csv = nil)
    name_total = 0

    # We should not be setting this here !!
    project_id = otu.project_id

    # TODO: scope this to name_remarks, keep internal
    if predicate_id = Predicate.find_by(
        uri: 'https://github.com/catalogueoflife/coldp#Name.remarks',
        project_id:)&.id

      ::Export::Coldp.remarks = ::Export::Coldp.get_remarks(otu.taxon_name.self_and_descendants, predicate_id)
    end

    # genderAgreement boolean is ultimately derivable from TaxonNameClassification::Gender

    output = ::CSV.generate(col_sep: "\t") do |csv|
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
        code
        status
        etymology
        gender
        link
        remarks
        modified
        modifiedBy
      }

      MANIFEST.each do |m|
        send( ('add_' + m.to_s).to_sym, otu, csv, project_members, reference_csv)
      end

      true
    end
  end

  # Higher names are:
  #   - valid higher names
  # Notes
  #   - candidate for merging with valid_family_names
  def self.valid_higher_names(otu)
    a = otu.taxon_name.self_and_descendants
      .where(rank_class: HIGHER_RANK_NAMES, cached_is_valid: true)
      .unscope(:order)
      .eager_load(origin_citation: [:source]) # TODO, just source_id, and pages
      .select(:id, :cached, :type, :cached_author_year, :cached_nomenclature_date, :rank_class, :updated_at, :updated_by_id)
  end

  # Valid family names are:
  #   - valid family group names
  def self.valid_family_names(otu)
    a = otu.taxon_name.self_and_descendants
      .where(rank_class: FAMILY_RANK_NAMES, cached_is_valid: true)
      .unscope(:order)
      .eager_load(origin_citation: [:source]) # TODO, just source_id, and pages
      .select(:id, :cached, :type, :cached_author_year, :cached_nomenclature_date, :rank_class, :updated_at, :updated_by_id)
  end

  # Invalid family/higher names
  def self.invalid_family_and_higher_names(otu)
    a = otu.taxon_name.self_and_descendants
      .where(
        type: 'Protonym',
        rank_class: FAMILY_RANK_NAMES + HIGHER_RANK_NAMES,
        cached_is_valid: false)
      .unscope(:order)
      .eager_load(origin_citation: [:source]) # TODO, just source_id, and pages
      .select(:id, :name, :type, :cached_author_year, :cached_nomenclature_date, :rank_class, :cached_is_valid, :cached_valid_taxon_name_id, :updated_at, :updated_by_id) # cached has sic
  end

  # Valid original combinations are:
  #   - species or genus group names
  #   - valid names
  #   - names with original combinations set
  #   - names where cached != original_combination, i.e. it needs re-ification
  #
  # As a test these should parse correctly in the Biodiversity wrapper as of 4/8/2025.
  #
  def self.original_combination_names(otu)
    a = core_names(otu)

    b = Protonym
      .original_combination_specified
      .original_combinations_flattened.with(project_scope: a)
      .where('taxon_names.cached != taxon_names.cached_original_combination') # Only reified!!
      .joins('JOIN project_scope ps on ps.id = taxon_names.id')
  end

  # Invalid original combinations are:
  #   - Species or genus group names
  #   - invalid names (not valid)
  #   - names with original combinations set
  #   - names where cached != original_combination, i.e. it needs re-ification
  #
  # These are the original combinations for invalid protonyms that need reified IDs
  #
  def self.invalid_original_combination_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    b = Protonym
      .original_combination_specified
      .original_combinations_flattened.with(valid_scope: a)
      .where(cached_is_valid: false)
      .where('taxon_names.cached != taxon_names.cached_original_combination') # Only reified!!
      .joins('JOIN valid_scope on valid_scope.id = taxon_names.cached_valid_taxon_name_id')
  end


  #
  # May have to split out misspellings from other invalid names to handle parens
  #
  #
  #
  def self.add_invalid_original_combination_names(otu, csv, project_members, reference_csv)

    # !!
    # !! Remember, the names here are loaded with values FROM THEIR ORIGINAL COMBINATIONS
    # !!
    names = invalid_original_combination_names(otu)
    names.length

    names.find_each do |row|
      # At this point all formatting (gender) is done
      elements = Protonym.original_combination_full_name_hash_from_flat(row)

      infraspecies, rank = Utilities::Nomenclature.infraspecies(elements)
      rank = 'forma' if rank == 'form' # CoL preferred string

      # Hmm- why needed?
      rank = elements.keys.last if rank.nil? # Note that this depends on order of Hash creation

      # Generic names can also be misspelled so, just process everything, don't bother checking the flag
      scientific_name = ::Utilities::Nomenclature.unmisspell_name(row['cached_original_combination'])

      # TODO: resolve/verify needed
      uninomial = scientific_name if rank == 'genus'

      # !! Ideally we de-reify these names in the query with (cached != cached_original_combination)
      # !! SO that we know these *must* be reified
      # !! We are reifying *without* "[sic]" in the string
      id = ::Utilities::Nomenclature.reified_id(row['id'], scientific_name)

      # By definition - for invalid names, the basionym points to itself (the reified original combination)
      basionym_id = id

      # !! g-maculata
      # if id == '1093903-f91ea42436b0bbf9a5115437e67afc27'
      #   byebug
      #   foo = 1
      # end

      # A major brain-@#$@#.
      # Original combinations of misspelled names
      # CAN have parenthesis in their rendering
      # if the original genus is different
      # THAN THE GENUS OF THE PROPERLY SPELLED VERSION OF THE NAME

      # Remember, 'genus' is `original_genus`, so
      # by the fact that synonyms are under the same parent
      # as that of the valid name we are comparing the
      # placement of the properly spelled version of the name.
      author_year = row['cached_author_year']

      strip_parens =
        !row['cached_misspelling'] ||
        row['cached'] =~ /\A#{Regexp.escape(row['genus'])}\b/

      author_year = author_year.delete('()') if strip_parens

      csv << [
        id,                                                                 # ID
        basionym_id,                                                        # basionymID
        scientific_name,                                                    # scientificName
        author_year,                                                        # authorship
        rank,                                                               # rank
        uninomial,                                                          # uninomial
        elements['genus']&.last,                                            # genus
        elements['subgenus']&.last,                                         # subgenus (no parens)
        elements['species']&.last,                                          # species
        infraspecies,                                                       # infraspecificEpithet
        row['source_id'],                                                   # referenceID
        row['pages'],                                                       # publishedInPage
        row['cached_nomenclature_date']&.year,                              # publishedInYear - OK
        code_field(row['reference_rank_class']),                            # code
        nil,                                                                # status https://api.checklistbank.org/vocab/nomStatus
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        nil,                                                                # remarks (we have no way to capture this in TW)
        Export::Coldp.modified(row[:updated_at]),                           # modified
        Export::Coldp.modified_by(row[:updated_by_id], project_members)     # modifiedBy
      ]

      # !! We do not need to add a reference here because it is the same as the corresponding Protonym id
    end
  end

  def self.add_original_combination_names(otu, csv, project_members, reference_csv)
    names = original_combination_names(otu)
    names.length

    names.find_each do |row|
      # At this point all formatting (gender) is done
      elements = Protonym.original_combination_full_name_hash_from_flat(row)

      infraspecies, rank = Utilities::Nomenclature.infraspecies(elements)
      rank = 'forma' if rank == 'form' # CoL preferred string

      # Hmm- why needed?
      rank = elements.keys.last if rank.nil? # Note that this depends on order of Hash creation

      scientific_name = ::Utilities::Nomenclature.unmisspell_name(row['cached_original_combination'])

      # TODO: resolve/verify needed
      uninomial = scientific_name if rank == 'genus'

      # !! Ideally we de-reify these names in the query with (cached != cached_original_combination)
      # !! So that we know these *must* be reified
      # !! We are reifieing *without* "[sic]" in the string
      id = ::Utilities::Nomenclature.reified_id(row['id'], scientific_name)

      # By definition
      basionym_id = row['id']

      csv << [
        id,                                                                 # ID
        basionym_id,                                                        # basionymID
        scientific_name,                                                    # scientificName
        row['cached_author_year'].gsub(/[\(\)]/, ''),                       # authorship  # TODO <- stripping author/year here
        rank,                                                               # rank
        uninomial,                                                          # uninomial
        elements['genus']&.last,                                            # genus
        elements['subgenus']&.last,                                         # subgenus (no parens)
        elements['species']&.last,                                          # species
        infraspecies,                                                       # infraspecificEpithet
        row['source_id'],                                                   # referenceID
        row['pages'],                                                       # publishedInPage
        row['cached_nomenclature_date']&.year,                              # publishedInYear - OK
        code_field(row['reference_rank_class']),                            # code
        nil,                                                                # status https://api.checklistbank.org/vocab/nomStatus
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        nil,                                                                # remarks (we have no way to capture this in TW)
        Export::Coldp.modified(row[:updated_at]),                           # modified
        Export::Coldp.modified_by(row[:updated_by_id], project_members)     # modifiedBy
      ]

      # !! We do not need to add a reference here because it is the same as the corresponding Protonym id
    end
  end

  def self.add_valid_family_names(otu, csv, project_members, reference_csv)
    names = valid_family_names(otu)
    names.length

    names.find_each do |t|
      origin_citation = t.origin_citation
      csv << [
        t.id,                                                               # ID
        nil,                                                                # basionymID
        t.cached,                                                           # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        t.cached,                                                           # uninomial
        nil,                                                                # genus and below - IIF species or lower
        nil,                                                                # infragenericEpithet (subgenus)
        nil,                                                                # specificEpithet
        nil,                                                                # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.cached_nomenclature_date&.year,                                   # publishedInYear
        code_field(t.rank_class.name),                                      # code
        ::TaxonName::NOMEN_VALID[t.rank_class.name.to_sym],                 # nomStatus
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  # TODO: could select less, don't need 'cached', just name?
  def self.add_valid_higher_names(otu, csv, project_members, reference_csv)
    names = valid_higher_names(otu)

    names.length
    names.find_each do |t|

      # TODO: isolate/refine
      origin_citation = t.origin_citation

      csv << [
        t.id,                                                               # ID
        nil,                                                                # basionymID
        t.cached,                                                           # scientificName  # should just be t.name?
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        t.cached,                                                           # uninomial
        nil,                                                                # genus and below - IIF species or lower
        nil,                                                                # infragenericEpithet (subgenus)
        nil,                                                                # specificEpithet
        nil,                                                                # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.cached_nomenclature_date&.year,                                   # publishedInYear
        code_field(t.rank_class.name),                                      # code
        ::TaxonName::NOMEN_VALID[t.rank_class.name.to_sym],                 # nomStatus
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  # Combinations
  #  - Differ from the present use of the name (i.e. we don't re-include as Chresonyms [yet])
  #  - SEE (TODO) .... for a-typical verbatim_names
  #
  # TODO: Complete combinations only
  # TODO: add .fully_specified ?
  #
  def self.combination_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    b = Combination
      .where('taxon_names.verbatim_name is null OR taxon_names.verbatim_name = taxon_names.cached') # !! verbatim_name when present is used in cached?! if so this isn't correct!
      .flattened
      .with(project_scope: a)
      .complete
      .joins('JOIN project_scope ps on ps.id = taxon_names.cached_valid_taxon_name_id') # Combinations that point to any of "a"
  end

  # Historical combinations that may not have Sources  [ or complete relationship records <- if not complete then not in ]
  # OR were skipped by add_combinations due to gender matching.
  #
  # These are Combinations that point to valid names in the OTU scope but weren't
  # actually written to CSV by add_combinations.
  #
  # TODO: why!?
  #
  # CHANGE TO  verbatim name != cached combinations
  #
  def self.historical_combination_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    # Exclude combinations that were actually exported (not skipped) by add_combinations
    # skipped_combinations contains IDs that combination_names returned but add_combinations skipped
    # We want to export those skipped ones here, so only exclude IDs that were NOT skipped
    exported_ids = combination_names(otu).pluck(:id) - ::Export::Coldp.skipped_combinations

    a = Combination
      .complete
      .with(project_scope: a)
      .joins('JOIN project_scope ps on ps.id = taxon_names.cached_valid_taxon_name_id')
      .where.not(id: exported_ids)
      .eager_load(origin_citation: [:source])

    b = a.pluck(:id).uniq!

    a
  end

  # TODO: we probably have an issue where self is not included as a relationship and we need to inject it into the data?
  def self.add_combination_names(otu, csv, project_members, reference_csv)
    names = combination_names(otu)
    names.length

    names.each do |row| # row is a Hash, not a ActiveRecord object

      # At this point all formatting (gender) is done
      elements = Combination.full_name_hash_from_row(row)

      # NOT POSSIBLE?! Combination can't have infraspecific in UI
      infraspecies, rank = Utilities::Nomenclature.infraspecies(elements)

      rank = elements.keys.last if rank.nil?

      # If this Combination is identical to the current placement we skip.
      #
      # Concluded that we don't need to try and keep the citations for these "skipped" names.
      #
      #   TODO: This exception needs to be in SQL to simply, a MAX/INDEX of possible ranks with values
      if row[rank + "_cached"] == row['cached']
        ::Export::Coldp.skipped_combinations << row['id']
        next
      end

      scientific_name = ::Utilities::Nomenclature.unmisspell_name(row['cached'])

      uninomial = scientific_name if rank == 'genus'

      # TODO - elements below need to be gender aligned.

      csv << [
        row['id'],                                                          # ID
        nil,                                                                # basionymID
        scientific_name,                                                    # scientificName
        row['cached_author_year'],                                          # authorship
        rank,                                                               # rank
        uninomial,                                                          # uninomial   <- if genus group only (i.e. incomplete Combination)
        elements['genus']&.last,                                            # genus
        elements['subgenus']&.last,                                         # subgenus (no parens)
        elements['species']&.last,                                          # species
        infraspecies,                                                       # infraspecificEpithet
        row['source_id'],                                                   # publishedInID
        row['pages'],                                                       # publishedInPage
        row['cached_nomenclature_date']&.year,                              # publishedInYear
        code_field(row['reference_rank_class']),                            # code
        nil,                                                                # nomStatus (nil for Combination)
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(row['id']),                          # remarks
        Export::Coldp.modified(row['updated_at']),                          # modified
        Export::Coldp.modified_by(row[:updated_by_id], project_members)     # modifiedBy
      ]
    end

    if reference_csv
      Source.with(names: names.where(citations: { is_original: true}))
        .joins('JOIN names n on n.source_id = sources.id')
        .find_each do |s|
          Export::Coldp::Files::Reference.add_reference_rows([s].compact, reference_csv, project_members)
        end
    end
  end

  # UNUSED
  # Export historical combinations that weren't captured by combination_names (flattened)
  # These may lack source citations or complete combination_taxon_names relationships
  def self.add_historical_combination_names(otu, csv, project_members, reference_csv)
    names = historical_combination_names(otu)

    names.find_each do |t|

      # TODO: skip in SQL, not here
      # Skip Combinations that are identical to the current valid placement
      valid_name = TaxonName.find_by(id: t.cached_valid_taxon_name_id)
      next if valid_name && t.cached == valid_name.cached

      origin_citation = t.origin_citation

      # Use full_name_hash to get the epithets
      elements = t.full_name_hash

      # Determine rank from protonyms_by_rank
      rank = t.protonyms_by_rank.keys.last&.to_s

      scientific_name = ::Utilities::Nomenclature.unmisspell_name(t.cached)

      uninomial = scientific_name if rank == 'genus'

      csv << [
        t.id,                                                               # ID
        nil,                                                                # basionymID
        scientific_name,                                                    # scientificName
        t.cached_author_year,                                               # authorship
        rank,                                                               # rank
        uninomial,                                                          # uninomial
        elements['genus']&.last,                                            # genus
        elements['subgenus']&.last&.gsub(/[\)\(]/, ''),                     # subgenus (no parens)
        elements['species']&.last,                                          # species
        elements['subspecies']&.last,                                       # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.year_of_publication,                                              # publishedInYear
        code_field(t.rank_class),                                           # code
        nil,                                                                # nomStatus (nil for Combination)
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link
        nil,                                                                # remarks
        Export::Coldp.modified(t.updated_at),                               # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members)         # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation&.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  # Return, based on the gender of the genus, the element
  # at the rank requested. Note infraspecies is a "fake" rank
  # that is combined data here. This is in part because
  # CoL only handles trinomials.
  #
  # @param rank - the element of the name requested
  #
  def self.align_gender(core_name, rank = :species)
    if g = core_name.genus_gender # there is a name at this rank and we can work with the gender

      case core_name.rank
      when 'species'
        core_name.send( (g + '_name').to_sym )
      when 'subspecies', 'form', 'variety' # See compression in core_names, may be an issue
        case rank
        when :species
          core_name.send( "species_#{g}_name".to_sym )
        when :infraspecies
          core_name.send( (g + '_name').to_sym )
        end
      end
    end
  end

  def self.add_core_names(otu, csv, project_members, reference_csv)
    names = core_names(otu)
    names.length

    names.find_each do |t|

      origin_citation = t.origin_citation
      basionym_id = t.id # by defintion
      uninomial = t.cached if t.rank == 'genus'

      # Future- resolve in SQL perhaps, though not very expensive here
      species = align_gender(t, :species)
      infraspecies = align_gender(t, :infraspecies)

      csv << [
        t.id,                                                               # ID
        basionym_id,                                                        # basionymID
        t.cached,                                                           # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        uninomial,                                                          # uninomial   <- if genus here
        t.genus,                                                            # genus and below - IIF species or lower # TODO: confirm this is OK now
        t.subgenus,                                                         # infragenericEpithet (subgenus)
        species,                                                            # specificEpithet
        infraspecies,                                                       # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.cached_nomenclature_date&.year,                                   # publishedInYear
        code_field(t.rank_class.name),                                      # code
        ::TaxonName::NOMEN_VALID[t.rank_class.name.to_sym],                 # nomStatus # TODO: untested
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  # @param classification_status Array
  # @param relationship_status Array
  def self.nomenclatural_status(taxon_name_id, classification_status = [], relationship_status = [])
    # Always prefer  a classification, regardless of age
    a = classification_status.bsearch{|i| i['taxon_name_id'] >= taxon_name_id}
    return a['type'].safe_constantize::NOMEN_URI if !a.blank? && a['taxon_name_id'] == taxon_name_id # binary is first >=
    b = relationship_status.bsearch{|i| i['subject_taxon_name_id'] >= taxon_name_id}
    return nil if b.blank? || b['subject_taxon_name_id'] != taxon_name_id
    return b['type'].safe_constantize::NOMEN_URI unless b.blank?
    nil
  end

  def self.add_invalid_family_and_higher_names(otu, csv, project_members, reference_csv)

    names = invalid_family_and_higher_names(otu)

    classification_status = taxon_name_classification_status(names)
    relationship_status = taxon_name_relationship_status(names)

    names.length # !! TODO: without this the result is truncated, why!?

    names.find_each do |t|
      origin_citation = t.origin_citation

      nom_status = nomenclatural_status(t.id, classification_status, relationship_status)

      csv << [
        t.id,                                                             # ID
        nil,                                                              # basionymID
        t.name,                                                           # scientificName
        t.cached_author_year,                                             # authorship
        t.rank,                                                           # rank
        t.name,                                                           # uninomial
        nil,                                                              # genus and below - IIF species or lower
        nil,                                                              # infragenericEpithet (subgenus)
        nil,                                                              # specificEpithet
        nil,                                                              # infraspecificEpithet
        origin_citation&.source_id,                                       # publishedInID
        origin_citation&.pages,                                           # publishedInPage
        t.cached_nomenclature_date&.year,                                 # publishedInYear
        code_field(t.rank_class.name),                                    # code
        nom_status,                                                       # nomStatus
        nil,                                                              # etymology
        nil,                                                              # gender
        nil,                                                              # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                             # remarks
        Export::Coldp.modified(t[:updated_at]),                           # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)     # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  def self.add_invalid_core_names(otu, csv, project_members, reference_csv)
    names = invalid_core_names(otu)

    classification_status = taxon_name_classification_status(names)
    relationship_status = taxon_name_relationship_status(names)

    names.length # !! TODO: without this the result is truncated, why!?

    names.find_each do |t|

      origin_citation = t.origin_citation

      scientific_name = t.cached_misspelling ? ::Utilities::Nomenclature.unmisspell_name(t.cached) : t.cached

      uninomial = scientific_name if t.rank == 'genus'

      nom_status = nomenclatural_status(t.id, classification_status, relationship_status)

      csv << [
        t.id,                                                               # ID
        nil,                                                                # basionymID
        scientific_name,                                                    # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        uninomial,                                                          # uninomial   <- if genus here
        t.genus,                                                            # genus and below - IIF species or lower
        t.subgenus,                                                         # infragenericEpithet (subgenus)
        t.species,                                                          # specificEpithet
        t.infraspecies,                                                     # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.cached_nomenclature_date&.year,                                   # publishedInYear
        code_field(t.rank_class.name),                                      # code
        nom_status,                                                         # nomStatus
        nil,                                                                # etymology
        nil,                                                                # gender
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

end
