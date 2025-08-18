# The synonym table is a list of all the Names (valid and invalid)
# that have been used for valid OTUs (Taxa) in the current classification.
#
# Only TaxonIds for valid OTUs {with valid taxon names} should be here, though the CoL parser format
# will apparently handle taxon ids that are not in the taxon table.
#
# Bigger picture: understand how this maps to core name usage table in CoL
#
# We assume that the names exporting in Names are those that must be tied to Taxa,
# so we re-use that scoping.
#
# !! TODO: While the scoping of names to be considered is likely correct,
# invalid names are not likely pointing to valid OTUs, but rather invalid OTUs.
#
# !? To resolve this create a single lookup of all possibile name_ids to their valid otu_id
# !! TODO: If a lookup is in place, then we can do this all in parallel with Name.tsv, i.e.
# completely removing a redundant pass
#
module Export::Coldp::Files::Synonym

  # @return String
  # Last 3 of https://api.checklistbank.org/vocab/taxonomicstatus
  def self.status(o, t)
    #'accepted'
    #'provisionally accepted'
    #'synonym'
    #'ambiguous synonym'
    #'missaplied'
    'synonym'
  end

  # @params otu [Otu]
  #   the top level OTU
  def self.generate(otu, otus, project_members, reference_csv = nil, skip_name_ids = [])
    ::CSV.generate(col_sep: "\t") do |csv|
      csv << %w{taxonID nameID status remarks referenceID modified modifiedBy}

      add_invalid_family_and_higher_names(otu, otus, csv, project_members)
      add_invalid_core_names(otu, otus, csv, project_members)
      add_original_combinations(otu, otus, csv, project_members)
      add_combinations(otu, otus, csv, project_members)
    end
  end

  def self.add_invalid_core_names(otu, otus, csv, project_members)


    names = ::Export::Coldp::Files::Name.invalid_core_names(otu)
    names.length # TODO: needed?

    x = Otu.with(name_scope: names)
      .joins('JOIN name_scope on name_scope.cached_valid_taxon_name_id = otus.taxon_name_id')
      .select(:id)

    y = TaxonName.with(invalid_names: names)
      .joins('JOIN invalid_names on invalid_names.cached_valid_taxon_name_id = taxon_names.id')
      .joins('LEFT JOIN otus on otus.taxon_name_id = taxon_names.id')
      .select('invalid_names.id, MAX(otus.id) AS otu_id, taxon_names.updated_at, taxon_names.updated_by_id') # housekeeping is meaningless here
      .group('taxon_names.id, invalid_names.id')

    y.find_each do |n|
      csv << [
        n.otu_id,                                                   # taxonID attached to the current valid concept
        n.id,                                                       # nameID
        nil,                                                        # status  TODO: def status(taxon_name_id)
        nil,                                                        # remarks
        nil,                                                        # referenceID  Unclear what this means in TW
        Export::Coldp.modified(n.updated_at),                       # modified
        Export::Coldp.modified_by(n.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  def self.add_combinations(otu, otus, csv, project_members)
    names = ::Export::Coldp::Files::Name.combination_names(otu).unscope(:select).select(:id, :cached_valid_taxon_name_id)

    x = Otu.with(name_scope: names)
      .joins('JOIN name_scope on name_scope.cached_valid_taxon_name_id = otus.taxon_name_id')
      .select(:id, :taxon_name_id)

    # TODO: ok to this point (check that we are not duplicating rows in y?

    y = TaxonName.with(invalid_names: names, otu_scope: x)
      .joins('JOIN invalid_names on invalid_names.id = taxon_names.id')
      .joins('LEFT JOIN otu_scope os on os.taxon_name_id = taxon_names.cached_valid_taxon_name_id')
      .select('invalid_names.id, MAX(os.id) AS otu_id, taxon_names.updated_at, taxon_names.updated_by_id') # housekeeping is meaningless here
      .group('taxon_names.id, invalid_names.id')

    y.find_each do |n|

      next if ::Export::Coldp.skipped_combinations.include?(n.id)

      csv << [
        n.otu_id,                                                  # taxonID attached to the current valid concept
        n.id,                                                      # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(n.updated_at),                      # modified
        Export::Coldp.modified_by(n.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  def self.add_invalid_family_and_higher_names(otu, otus, csv, project_members)
    names = ::Export::Coldp::Files::Name.invalid_family_and_higher_names(otu)
    names.length # TODO: needed?

    x = Otu.with(name_scope: names)
      .joins('JOIN name_scope on name_scope.cached_valid_taxon_name_id = otus.taxon_name_id')
      .select(:id)

    y = TaxonName.with(invalid_names: names)
      .joins('JOIN invalid_names on invalid_names.cached_valid_taxon_name_id = taxon_names.id')
      .joins('LEFT JOIN otus on otus.taxon_name_id = taxon_names.id')
      .select('invalid_names.id, MAX(otus.id) AS otu_id, taxon_names.updated_at, taxon_names.updated_by_id') # housekeeping is meaningless here
      .group('taxon_names.id, invalid_names.id')

    #   x = Otu.with(name_scope: names)
    #     .joins('JOIN name_scope on name_scope.id = otus.taxon_name_id')
    #     .select(:id)

    #   y = Otu.with(otu_scope: x)
    #     .joins('JOIN otu_scope on otu_scope.id = otus.id')
    #     .select(:id, :taxon_name_id, :updated_at, :updated_by_id)

    y.find_each do |n|
      csv << [
        n.otu_id,                                                  # taxonID attached to the current valid concept
        n.id,                                                      # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(n.updated_at),                      # modified
        Export::Coldp.modified_by(n.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  def self.add_original_combinations(otu, otus, csv, project_members)
    names = ::Export::Coldp::Files::Name.original_combination_names(otu)

    x = Otu.with(name_scope: names)
      .joins('JOIN name_scope on name_scope.cached_valid_taxon_name_id = otus.taxon_name_id')
      .select(:id)

    y = TaxonName.with(invalid_names: names)
      .joins('JOIN invalid_names on invalid_names.cached_valid_taxon_name_id = taxon_names.id')
      .joins('LEFT JOIN otus on otus.taxon_name_id = taxon_names.id')
      .select('invalid_names.id, MAX(otus.id) AS otu_id, taxon_names.updated_at, taxon_names.updated_by_id, invalid_names.cached_original_combination') # housekeeping is meaningless here
      .group('taxon_names.id, invalid_names.id, invalid_names.cached_original_combination')

    #   a = Otu.with(name_scope: names, otu_scope: otus)
    #     .joins('JOIN name_scope on name_scope.id = otus.taxon_name_id')
    #     .joins('JOIN otu_scope on otu_scope.id = otus.id')
    #     .select('otus.id, otus.taxon_name_id, otus.updated_at, otus.updated_by_id, name_scope.cached_original_combination').distinct

    y.find_each do |n|
      # By `original_combination_names(otu) these are all reified
      reified_id = ::Utilities::Nomenclature.reified_id(n.id, n.cached_original_combination)

      csv << [
        n.otu_id,                                                  # taxonID attached to the current valid concept
        reified_id,                                                # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(n.updated_at),                      # modified
        Export::Coldp.modified_by(n.updated_by_id, project_members) # modifiedBy
      ]
    end
  end


=begin
  # This is currently factored to use *no* ActiveRecord instances
  #   TODO: mirror Name generation, remove the n=1 otus
  #
  def self.generate2(otus, project_members, reference_csv = nil, skip_name_ids = [])
    ::CSV.generate(col_sep: "\t") do |csv|

      csv << %w{taxonID nameID status remarks referenceID modified modifiedBy}

      # Only valid otus with taxon names, see lib/export/coldp.rb#otus
      #  ?! in groups of
      otus.select('otus.id id, taxon_names.cached cached, otus.taxon_name_id taxon_name_id')
        .pluck(:id, :cached, :taxon_name_id)
        .find_each do |o|

          # TODO: Confirm resolved: original combinations of invalid names are not being handled correclty in reified

          # Here we grab the hierarchy again, and filter it by
          #   1) allow only invalid names OR names with differing original combinations
          #   2) of 1) eliminate Combinations with identical names to current placement
          #
          a = TaxonName.that_is_invalid
            .where(cached_valid_taxon_name_id: o[2])
            .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", o[1]) # Hybrids allowed, intended?

          b = TaxonName.where(cached_valid_taxon_name_id: o[2])
            .where('(taxon_names.cached_original_combination != taxon_names.cached)')
            .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", o[1])

          c = ::Queries.union(TaxonName, [a,b])

          # Hernán notes:
          # TaxonName.where(cached_valid_taxon_name_id: 42).merge(TaxonName.where.not(type: 'Combination').or(TaxonName.where.not(cached: 'Forty two'))).to_sql
          # Mjy - "or" performance is bad? or?

          # Original concept
          # TaxonName
          #   .where(cached_valid_taxon_name_id: o[2]) # == .historical_taxon_names
          #   .where("( ((taxon_names.id != taxon_names.cached_valid_taxon_name_id) OR ((taxon_names.cached_original_combination != taxon_names.cached))) AND NOT (taxon_names.type = 'Combination' AND taxon_names.cached = ?))", o[1]) # see name.rb

          c.pluck(:id, :cached, :cached_original_combination, :type, :rank_class, :cached_secondary_homonym, :updated_at, :updated_by_id)
            .each do |t|
              reified_id = ::Export::Coldp.reified_id(t[0], t[1], t[2])
              next if skip_name_ids.include? reified_id = ::Export::Coldp.reified_id(t[0], t[1], t[2])


              # skip duplicate protonyms created for family group relationships
              if t[4]&.include? 'FamilyGroup'
                tn = TaxonName.find(t[0])
                if tn.taxon_name_relationships.any? {|tnr| tnr.type == 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm'}
                  if tn.name == o[1]  # only skip if it matches the accepted name, because there might be multiple protonyms added for family group relationships
                    next
                  end
                end
              end

              # skips including parent binomial as a synonym of autonym trinomial
              # TODO: may need to handle cases in which the gender stems are not an exact match
              matches = t[1].match(/([A-Z][a-z]+) \(.+\) ([a-z]+)/)
              cached = t[1]
              if matches&.size == 3
                cached = "#{matches[1]} #{matches[2]}"
              end
              unless t[5].nil?
                if !t[1].nil? and cached.include? t[5] and (t[4].match(/::Subspecies$/) or t[4].match(/::Form$/) or t[4].match(/::Variety$/))
                  next
                end

                if !t[2].nil? and t[2].include? t[5] and o[1].include? t[5] and t[4].match(/::Species$/)
                  next
                end
              end

              # TODO: This code block is erroneously removing basionyms from the synonyms section but we may need an improved form of it to remove duplicate synonyms (https://github.com/SpeciesFileGroup/taxonworks/issues/3482)
              # matches = t[1].match(/([A-Z][a-z]+) \(.+\) ([a-z]+)/)
              #
              # if matches&.size == 3        # cached_original_combination != cached_secondary_homonym
              #   if t[5] == "#{matches[1]} #{matches[2]}" and t[2] != t[5]
              #     next
              #   end
              # end

              # skips combinations including parent binomial as a synonym of autonym trinomial
              if t[3] == 'Combination' and o[1].include? t[1]
                next
              end

              # skip making parent genus Aus a synonym of subgenus autonym (Aus) Aus
              autonym_test = t[1]&.gsub(/\(/, '')&.gsub(/\)/, '')&.split(' ')
              if t[4]&.include?('Subgenus') && autonym_test.size >= 2 && autonym_test[0] == autonym_test[1] && t[2] == autonym_test[0]
                next
              end

              csv << [
                o[0],                                             # taxonID attached to the current valid concept
                reified_id,                                       # nameID
                nil,                                              # status  TODO: def status(taxon_name_id)
                Export::Coldp.sanitize_remarks(remarks_field),    # remarks
                nil,                                              # referenceID  Unclear what this means in TW
                Export::Coldp.modified(t[6]),                     # modified
                Export::Coldp.modified_by(t[7], project_members)  # modifiedBy
              ]
            end
        end
    end
end
=end
end
