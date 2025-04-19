# The names table includes
# * All name strings, even if hanging (= not attached to OTUs/Taxa)
# * It contains strings that may be invalid OR valid
#
# Future considerations
#   - see bottom, should we parameterize a CSV row add, is it performat?, it
#   would let us DRY all csv << , but it's also not dry to parameterize.
#   Probably OK as is.
#
# TODO:
#  - [ ] refactor ref additions so that they happen at the aggregate level
#  - [ ] resolve the `.length` issue, what the heck is that needed for
#
module Export::Coldp::Files::Name

  # TODO: Not implemented, resolve
  # and re-implement if needed
  # @skipped_name_ids = []
  #

  # def self.skipped_name_ids
  #   @skipped_name_ids
  # end

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

    # TODO: adding .that_is_valid increases names, why?  Are we hitting duplicates?
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    # b sets up the query that aggregates the different ranks in one row
    b = ::Protonym.is_species_or_genus_group.with(valid_scope: a)
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
      .eager_load(origin_citation: [:source])
      .select('taxon_names.*, n.genus, n.subgenus, n.species, n.infraspecies')
  end

  def self.invalid_core_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order).select(:id)

    b = ::Protonym.is_species_or_genus_group.where(cached_is_valid: false).with(valid_scope: a)
      .joins('JOIN valid_scope on valid_scope.id = taxon_names.cached_valid_taxon_name_id')
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
      .where(cached_is_valid: false) # redundant
      .joins('JOIN n on n.id = taxon_names.id')
      .eager_load(origin_citation: [:source])
      .select('taxon_names.*, n.genus, n.subgenus, n.species, n.infraspecies')
  end

  # @params otu [Otu]
  #   the top level OTU
  def self.generate(otu, project_members, reference_csv = nil)
    name_total = 0

    # We should not be setting this here !!
    project_id = otu.project_id

    if predicate_id = Predicate.find_by(
        uri: 'https://github.com/catalogueoflife/coldp#Name.remarks',
        project_id:)&.id

      ::Export::Coldp.remarks = ::Export::Coldp.get_remarks(otu.taxon_name.self_and_descendants, predicate_id)
    end

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

      add_valid_higher_names(otu, csv, project_members, reference_csv)
      add_valid_family_names(otu, csv, project_members, reference_csv)
      add_core_names(otu, csv, project_members, reference_csv)
      add_combinations(otu, csv, project_members, reference_csv)
      add_original_combinations(otu, csv, project_members, reference_csv)
      add_invalid_family_and_higher_names(otu, csv, project_members, reference_csv)
      add_invalid_core_names(otu, csv, project_members, reference_csv)
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
      .select(:id, :cached, :type, :cached_author_year, :year_of_publication, :rank_class, :updated_at, :updated_by_id)
    end

  # Valid family names are:
  #   - valid family group names
  def self.valid_family_names(otu)
    a = otu.taxon_name.self_and_descendants
      .where(rank_class: FAMILY_RANK_NAMES, cached_is_valid: true)
      .unscope(:order)
      .select(:id, :cached, :type, :cached_author_year, :year_of_publication, :rank_class, :updated_at, :updated_by_id)
      .eager_load(origin_citation: [:source]) # TODO, just source_id, and pages
  end

  # TODO: Probably break out invalid family and test for reified there
  # Invalid family/higher names
  def self.invalid_family_and_higher_names(otu)
    a = otu.taxon_name.self_and_descendants
      .where(
        type: 'Protonym',
        rank_class: FAMILY_RANK_NAMES + HIGHER_RANK_NAMES,
        cached_is_valid: false)
      .unscope(:order)
      .select(:id, :name, :type, :cached_author_year, :year_of_publication, :rank_class, :cached_is_valid, :cached_valid_taxon_name_id, :updated_at, :updated_by_id) # cached has sic
      .eager_load(origin_citation: [:source]) # TODO, just source_id, and pages
  end

  # Valid original combinations are:
  #   - species or genus group names
  #   - valid names
  #   - names with original combinations set
  #
  # As a test these should parse correctly in the Biodiversity wrapper as of 4/8/2025.
  #
  def self.original_combination_names(otu)
    a = otu.taxon_name.self_and_descendants
      .where(taxon_names: { type: 'Protonym' })
      .select(:id)
      .unscope(:order)

    b = Protonym
      .original_combination_specified
      .original_combinations_flattened.with(project_scope: a)
      .joins('JOIN project_scope ps on ps.id = taxon_names.id')
  end

  def self.add_original_combinations(otu, csv, project_members, reference_csv)
    names = original_combination_names(otu)
    names.length

    names.find_each do |row|

      # At this point all formatting (gender) is done
      elements = Protonym.original_combination_full_name_hash_from_flat(row)

      infraspecies, rank = Utilities::Nomenclature.infraspecies(elements)
      rank = 'forma' if rank == 'form' # CoL preferred string
      rank = elements.keys.last if rank.nil? # Note that this depends on order of Hash creation

      # TODO: resolve/verify needed
      uninomial = row['genus'] if rank == 'genus'

      id = ::Utilities::Nomenclature.reified_id(row['id'], row['cached_original_combination'])

      # by definition
      basionym_id = row['id']

      csv << [
        id,                                                                 # ID
        basionym_id,                                                        # basionymID
        row['cached_original_combination'],                                 # scientificName
        row['cached_author_year'].gsub(/[\(\)]/, ''),                       # authorship
        rank,                                                               # rank
        uninomial,                                                          # uninomial
        row['genus'],                                                       # genus
        row['subgenus'],                                                    # subgenus (no parens)
        row['species'],                                                     # species
        infraspecies,                                                       # infraspecificEpithet
        row['source_id'],                                                   # referenceID
        row['pages'],                                                       # publishedInPage
        row['cached_nomenclature_date']&.year,                              # publishedInYear
        true,                                                               # original
        code_field(row['reference_rank_class']),                            # code
        nil,                                                                # status https://api.checklistbank.org/vocab/nomStatus
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
        t.rank,                                                              # rank
        nil,                                                                # uninomial   <- if genus here
        nil,                                                                # genus and below - IIF species or lower
        nil,                                                                # infragenericEpithet (subgenus)
        nil,                                                                # specificEpithet
        nil,                                                                # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.year_of_publication,                                              # publishedInYear
        code_field(t.rank_class.name),                                      # code
        ::TaxonName::NOMEN_VALID[t.rank_class.name.to_sym],                 # nomStatus
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  def self.add_valid_higher_names(otu, csv, project_members, reference_csv)
    names = valid_higher_names(otu)

    names.length
    names.find_each do |t|

      # TODO: isolate/refine
      origin_citation = t.origin_citation

      csv << [
        t.id,                                                               # ID
        nil,                                                                # basionymID
        t.cached,                                                             # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        nil,                                                                # uninomial   <- if genus here
        nil,                                                                # genus and below - IIF species or lower
        nil,                                                                # infragenericEpithet (subgenus)
        nil,                                                                # specificEpithet
        nil,                                                                # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.year_of_publication,                                              # publishedInYear
        code_field(t.rank_class.name),                                      # code
        ::TaxonName::NOMEN_VALID[t.rank_class.name.to_sym],                 # nomStatus
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  # TODO: Complete combinations only
  # TODO: add .fully_specified ?
  def self.combination_names(otu)
    a = otu.taxon_name.self_and_descendants.unscope(:order)
      .where(taxon_names: { type: 'Combination' })
      .select(:id)

    b = Combination.
      flattened.with(project_scope: a)
      .complete
      .joins('JOIN project_scope ps on ps.id = taxon_names.id')
  end

  # TODO: we probably have an issue where self is not included as a relationship and we need to inject it into the data?
  def self.add_combinations(otu, csv, project_members, reference_csv)
    names = combination_names(otu)
    names.length
    names.each do |row| # row is a Hash, not a ActiveRecord object

      # TODO:
      # basionym_id = nil # t.reified_id # See original combination
      # basionym_id = nil if @skipped_name_ids.include?(basionym_id)

      # At this point all formatting (gender) is done
      elements = Combination.full_name_hash_from_row(row)

      infraspecies, rank = Utilities::Nomenclature.infraspecies(elements)
      rank = elements.keys.last if rank.nil? # Note that this depends on order of Hash creation

      # TODO: resolve/verify needed
      uninomial = row['genus'] if rank == 'genus'

      csv << [
        row['id'],                                                          # ID
        nil, #basionym_id,                                                  # basionymID
        row['cached'],                                                      # scientificName  # should just be t.cached
        row['cached_author_year'],                                          # authorship
        rank,                                                               # rank
        uninomial,                                                          # uninomial   <- if genus here
        elements[:genus],                                                   # genus and below - IIF species or lower # TODO: confirm this is OK now
        elements[:subgenus],                                                # infragenericEpithet (subgenus)
        elements[:species],                                                 # specificEpithet
        infraspecies,                                                       # infraspecificEpithet
        row['source_id'],                                                   # publishedInID
        row['pages'],                                                       # publishedInPage
        row['cached_nomenclature_date']&.year,                              # publishedInYear
        code_field(row['reference_rank_class']),                            # code
        nil,                                                                # nomStatus (nil for Combination)
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(row['id']),                               # remarks
        Export::Coldp.modified(row['updated_at']),                          # modified
        Export::Coldp.modified_by(row[:updated_by_id], project_members)     # modifiedBy
      ]

      # TODO: will have to update this to generate from id
      # Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  def self.add_core_names(otu, csv, project_members, reference_csv)
    names = core_names(otu)
    names.length
    names.find_each do |t|

      # name_total += 1

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

      # TODO: remove this loop, using a with to top
      # ... This eliminates Combinations that are identical to the current placement.
      #

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
      basionym_id = t.id # by defintion
      uninomial = t.cached if t.rank == 'genus'

      csv << [
        t.id,                                                               # ID
        basionym_id,                                                        # basionymID
        t.cached,                                                           # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        uninomial,                                                          # uninomial   <- if genus here
        t.genus,                                                            # genus and below - IIF species or lower # TODO: confirm this is OK now
        t.subgenus,                                                         # infragenericEpithet (subgenus)
        t.species,                                                          # specificEpithet
        t.infraspecies,                                                     # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.year_of_publication,                                              # publishedInYear
        code_field(t.rank_class.name),                                      # code
        ::TaxonName::NOMEN_VALID[t.rank_class.name.to_sym],                 # nomStatus # TODO: untested
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


  # TODO: reconcile this:
  #
  # # Here we add reified ID's for higher taxa in which cached != cached_original_combination (e.g., TaxonName stores both Lamotialnina and Lamotialnini so needs a reified ID)
  # if t.cached_original_combination.present? && t.is_family_rank? && t.has_alternate_original? # t.cached != t.cached_original_combination
  #   add_higher_original_name(t, csv, origin_citation, name_remarks_vocab_id, project_members)
  # end
  #
  def self.add_invalid_family_and_higher_names(otu, csv, project_members, reference_csv)

    names =  invalid_family_and_higher_names(otu)

    classification_status = taxon_name_classification_status(names)
    relationship_status = taxon_name_relationship_status(names)

    names.length # !! TODO: without this the result is truncated, why!?

    names.find_each do |t|
      origin_citation = t.origin_citation

      nom_status = nomenclatural_status(t.id, classification_status, relationship_status)

      csv << [
        t.id,                                                             # ID
        nil,                                                              # basionymID
        t.name,                                                           # scientificName  # should just be t.cached
        t.cached_author_year,                                             # authorship
        t.rank,                                                           # rank
        nil,                                                              # uninomial   <- if genus here
        nil,                                                              # genus and below - IIF species or lower
        nil,                                                              # infragenericEpithet (subgenus)
        nil,                                                              # specificEpithet
        nil,                                                              # infraspecificEpithet
        origin_citation&.source_id,                                       # publishedInID
        origin_citation&.pages,                                           # publishedInPage
        t.year_of_publication,                                            # publishedInYear
        code_field(t.rank_class.name),                                    # code
        nom_status,                                                       # nomStatus
        nil,                                                              # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                             # remarks
        Export::Coldp.modified(t[:updated_at]),                           # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)     # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

  # TODO: use similar strategy to implement TNR relationship statuses, at least for
  # homonyms.
  #
  def self.add_invalid_core_names(otu, csv, project_members, reference_csv)
    names = invalid_core_names(otu)

    classification_status = taxon_name_classification_status(names)
    relationship_status = taxon_name_relationship_status(names)

    names.length # !! TODO: without this the result is truncated, why!?

    names.find_each do |t|

      origin_citation = t.origin_citation

      # basionym_id = nil if @skipped_name_ids.include?(basionym_id)
      uninomial = t.cached if t.rank == 'genus'

      scientific_name = t.cached_misspelling ? ::Utilities::Nomenclature.unmisspell_name(t.cached) : t.cached

      nom_status = nomenclatural_status(t.id, classification_status, relationship_status)

      csv << [
        t.id,                                                               # ID
        nil,                                                                # basionymID
        scientific_name,                                                           # scientificName  # should just be t.cached
        t.cached_author_year,                                               # authorship
        t.rank,                                                             # rank
        uninomial,                                                          # uninomial   <- if genus here
        t.genus,                                                            # genus and below - IIF species or lower
        t.subgenus,                                                         # infragenericEpithet (subgenus)
        t.species,                                                          # specificEpithet
        t.infraspecies,                                                     # infraspecificEpithet
        origin_citation&.source_id,                                         # publishedInID
        origin_citation&.pages,                                             # publishedInPage
        t.year_of_publication,                                              # publishedInYear
        code_field(t.rank_class.name),                                      # code
        nom_status,                                                         # nomStatus
        nil,                                                                # link (probably TW public or API)
        Export::Coldp.sanitize_remarks(t.id),                               # remarks
        Export::Coldp.modified(t[:updated_at]),                             # modified
        Export::Coldp.modified_by(t[:updated_by_id], project_members)       # modifiedBy
      ]

      Export::Coldp::Files::Reference.add_reference_rows([origin_citation.source].compact, reference_csv, project_members) if reference_csv && origin_citation
    end
  end

=begin

TODO: Benchmark performance of pre-mapping and then writing

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
=end

end
