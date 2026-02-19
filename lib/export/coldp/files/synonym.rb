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
      add_original_combinations(otu, csv, project_members, otu_lookup)  # Handles reified IDs
      add_invalid_original_combinations(otu, csv, project_members, otu_lookup)  # Handles reified IDs
      add_combinations(otu, csv, project_members, otu_lookup)
      # add_historical_combinations(otu, csv, project_members, otu_lookup)
    end
  end

  def self.add_invalid_core_names(otu, csv, project_members, otu_lookup)
    names = ::Export::Coldp::Files::Name.invalid_core_names(otu)
    names.length # !! Required - without this the result is truncated (see name.rb comment)

    # Iterate directly over names (like name.rb does) to avoid CTE truncation issues
    names.find_each do |t|

      # Names like missaplications do not point to a valid name, i.e. their id == cached_valid_taxon_.
      #  - Add a synonym relationships to have them appear here.
      #  - Names skipped here are treated as bare names in CoL
      taxon_id =  otu_lookup[t.cached_valid_taxon_name_id]
      next unless taxon_id

      csv << [
        taxon_id,                                                   # taxonID attached to the current valid concept
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

  # # Add synonyms for historical combinations that weren't captured by combination_names (flattened)
  # def self.add_historical_combinations(otu, csv, project_members, otu_lookup)
  #   names = ::Export::Coldp::Files::Name.historical_combination_names(otu)

  #   # Build a lookup for valid taxon names to check current placement
  #   valid_name_lookup = TaxonName.where(id: otu_lookup.keys).pluck(:id, :cached).to_h

  #   names.find_each do |t|
  #     # Skip Combinations that are identical to the current valid placement
  #     valid_cached = valid_name_lookup[t.cached_valid_taxon_name_id]
  #     next if valid_cached && t.cached == valid_cached

  #     csv << [
  #       otu_lookup[t.cached_valid_taxon_name_id],                  # taxonID attached to the current valid concept
  #       t.id,                                                      # nameID
  #       nil,                                                       # status  TODO: def status(taxon_name_id)
  #       nil,                                                       # remarks
  #       nil,                                                       # referenceID  Unclear what this means in TW
  #       Export::Coldp.modified(t.updated_at),                      # modified
  #       Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
  #     ]
  #   end
  # end

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
        otu_lookup[t.cached_valid_taxon_name_id],                   # taxonID attached to the current valid concept
        reified_id,                                                 # nameID
        nil,                                                        # status  TODO: def status(taxon_name_id)
        nil,                                                        # remarks
        nil,                                                        # referenceID  Unclear what this means in TW
        Export::Coldp.modified(t.updated_at),                       # modified
        Export::Coldp.modified_by(t.updated_by_id, project_members) # modifiedBy
      ]
    end
  end
end
