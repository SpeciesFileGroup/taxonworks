# The synonym table is simply a list of all the Names that have been used for valid OTUs (Taxa) in the current classification
# regardless of whether they are valid or invalid names.  Only TaxonIds for valid OTUs should be here, though the format
# will apparently handle taxon ids that are not in the taxon table.

# Bigger picture: understand how this maps to core name usage table in CoL
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

  def self.remarks_field
    nil
  end

  def self.reference_id_field(otu)
    nil
  end

  # This is currently factored to use *no* ActiveRecord instances
  def self.generate(otus, reference_csv = nil)
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{taxonID nameID status remarks referenceID}

      # Only valid otus with taxon names, see lib/export/coldp.rb#otus
      otus.select('otus.id id, taxon_names.cached cached, otus.taxon_name_id taxon_name_id')
        .pluck(:id, :cached, :taxon_name_id)
        .each do |o|

          # TODO: Confirm resolved: original combinations of invalid names are not being handled correclty in reified

          # Here we grab the hierarchy again, and filter it by
          #   1) allow only invalid names OR names with differing original combinations
          #   2) of 1) eliminate Combinations with identical names to current placement
          #
          a = TaxonName.that_is_invalid
            .where(cached_valid_taxon_name_id: o[2])
            .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", o[1])

          b = TaxonName.where(cached_valid_taxon_name_id: o[2])
            .where("(taxon_names.cached_original_combination != taxon_names.cached)")
            .where.not("(taxon_names.type = 'Combination' AND taxon_names.cached = ?)", o[1])

          c = TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")

          # Hernán notes:
          # TaxonName.where(cached_valid_taxon_name_id: 42).merge(TaxonName.where.not(type: 'Combination').or(TaxonName.where.not(cached: 'Forty two'))).to_sql

          # Original concept
          # TaxonName
          #   .where(cached_valid_taxon_name_id: o[2]) # == .historical_taxon_names
          #   .where("( ((taxon_names.id != taxon_names.cached_valid_taxon_name_id) OR ((taxon_names.cached_original_combination != taxon_names.cached))) AND NOT (taxon_names.type = 'Combination' AND taxon_names.cached = ?))", o[1]) # see name.rb

          c.pluck(:id, :cached, :cached_original_combination, :type, :rank_class, :cached_secondary_homonym)
            .each do |t|
              reified_id = ::Export::Coldp.reified_id(t[0], t[1], t[2])

              # skips including parent binomial as a synonym of autonym trinomial
              unless t[5].nil?
                if !t[1].nil? and t[1].include? t[5] and (t[4].match(/::Subspecies$/) or t[4].match(/::Form$/) or t[4].match(/::Variety$/))
                  next
                end

                if !t[2].nil? and t[2].include? t[5] and o[1].include? t[5] and t[4].match(/::Species$/)
                  next
                end
              end

              matches = t[1].match(/([A-Z][a-z]+) \(.+\) ([a-z]+)/)
              if matches&.size == 3
                if t[5] == "#{matches[1]} #{matches[2]}" and t[2] != t[5]
                  next
                end
              end

              # skips combinations including parent binomial as a synonym of autonym trinomial
              if t[3] == 'Combination' and o[1].include? t[1]
                next
              end

              csv << [
                o[0],           # taxonID attached to the current valid concept
                reified_id,     # nameID
                nil,            # Status TODO def status(taxon_name_id)
                remarks_field,
                nil,            # Unclear what this means in TW
              ]
            end
        end
    end
  end

  # It is unclear what the relationship beyond "used" means. We likely need a sensu style model to record these assertions
  # Export::Coldp::Files::Reference.add_reference_rows([], reference_csv) if reference_csv
end
