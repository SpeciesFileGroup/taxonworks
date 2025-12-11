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
  def self.generate(otu, otus, project_members, reference_csv = nil)
    # Build OTU lookup hash once to avoid N+1 queries
    # Maps taxon_name_id -> otu.id for all OTUs in scope
    otu_lookup = otus.pluck(:taxon_name_id, :id).to_h

    ::CSV.generate(col_sep: "\t") do |csv|
      csv << %w{taxonID nameID status remarks referenceID modified modifiedBy}

      add_invalid_family_and_higher_names(otu, csv, project_members, otu_lookup)
      add_invalid_core_names(otu, csv, project_members, otu_lookup)
      add_original_combinations(otu, csv, project_members, otu_lookup)
      add_invalid_original_combinations(otu, csv, project_members, otu_lookup)
      add_combinations(otu, csv, project_members, otu_lookup)
      add_historical_combinations(otu, csv, project_members, otu_lookup)
    end
  end

  def self.add_invalid_core_names(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.invalid_core_names(otu)
    names.length # !! Required - without this the result is truncated (see name.rb comment)

    # Iterate directly over names (like name.rb does) to avoid CTE truncation issues
    names.find_each do |t|
      csv << [
        otu_lookup[t.cached_valid_taxon_name_id],                   # taxonID attached to the current valid concept
        t.id,                                                       # nameID
        nil,                                                        # status  TODO: def status(taxon_name_id)
        nil,                                                        # remarks
        nil,                                                        # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                       # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  def self.add_combinations(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.combination_names(otu).unscope(:select).select('taxon_names.*')
    names.length # !! Required - without this the result is truncated (see name.rb comment)

    # Iterate directly over names to avoid CTE truncation issues
    names.find_each do |t|
      next if ::Export::Coldp.skipped_combinations.include?(t.id)

      csv << [
        otu_lookup[t.cached_valid_taxon_name_id],                  # taxonID attached to the current valid concept
        t.id,                                                      # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                      # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  # Add synonyms for historical combinations that weren't captured by combination_names (flattened)
  def self.add_historical_combinations(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.historical_combination_names(otu)

    # Build a lookup for valid taxon names to check current placement
    valid_name_lookup = TaxonName.where(id: otu_lookup.keys).pluck(:id, :cached).to_h

    names.find_each do |t|
      # Skip Combinations that are identical to the current valid placement
      valid_cached = valid_name_lookup[t.cached_valid_taxon_name_id]
      next if valid_cached && t.cached == valid_cached

      csv << [
        otu_lookup[t.cached_valid_taxon_name_id],                  # taxonID attached to the current valid concept
        t.id,                                                      # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                      # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  def self.add_invalid_family_and_higher_names(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.invalid_family_and_higher_names(otu)
    names.length # !! Required - without this the result is truncated (see name.rb comment)

    # Iterate directly over names to avoid CTE truncation issues
    names.find_each do |t|
      csv << [
        otu_lookup[t.cached_valid_taxon_name_id],                  # taxonID attached to the current valid concept
        t.id,                                                      # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                      # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  def self.add_original_combinations(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.original_combination_names(otu)
    names.length # !! Required - without this the result is truncated (see name.rb comment)

    # Iterate directly over names to avoid CTE truncation issues
    names.find_each do |t|
      # By `original_combination_names(otu) these are all reified
      reified_id = ::Utilities::Nomenclature.reified_id(t.id, t.cached_original_combination)

      csv << [
        otu_lookup[t.cached_valid_taxon_name_id],                  # taxonID attached to the current valid concept
        reified_id,                                                # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                      # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
      ]
    end
  end

  # Add synonyms for invalid names with different original combinations (reified IDs)
  def self.add_invalid_original_combinations(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.invalid_original_combination_names(otu)
    names.length # !! Required - without this the result is truncated (see name.rb comment)

    # Iterate directly over names to avoid CTE truncation issues
    names.find_each do |t|
      # By `invalid_original_combination_names(otu) these are all reified
      reified_id = ::Utilities::Nomenclature.reified_id(t.id, t.cached_original_combination)

      csv << [
        otu_lookup[t.cached_valid_taxon_name_id],                  # taxonID attached to the current valid concept
        reified_id,                                                # nameID
        nil,                                                       # status  TODO: def status(taxon_name_id)
        nil,                                                       # remarks
        nil,                                                       # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                      # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
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
