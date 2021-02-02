# The synonym table is simply a list of all the Names that have been used for valid OTUs (Taxa) in the current classification
# regardless of whether they are valid or invalid names.  Only TaxonIds for valid OTUs should be here, though the format
# will apparently handle taxon ids that are not in the taxon table.

# Bigger picture: understand how this maps to core name usage table in CoL
#
module Export::Coldp::Files::Synonym

  # @return String
  # Last 3 of https://api.catalogue.life/vocab/taxonomicstatus
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

      # Otus are valid and invalid
      otus.joins(:taxon_name)
        .where.not(taxon_name_id: nil)
        .where('taxon_names.id = taxon_names.cached_valid_taxon_name_id')
        .select('otus.id id, taxon_names.cached cached')
        .pluck(:id, :cached, :taxon_name_id)
        .each do |o|

          #  name = o.taxon_name
          # original combinations of invalid names are not being handled correclty in reified


          # Here we grab the hierarch again, and filter it by
          #   1) allow only invalid names OR names with differing original combinations
          #   2) of 1) eliminate Combinations with identical names to current placement
          TaxonName
            .where(cached_valid_taxon_name_id: o[2]) # == .historical_taxon_names
            .where("( ((taxon_names.id != taxon_names.cached_valid_taxon_name_id) OR ((taxon_names.cached_original_combination != taxon_names.cached))) AND NOT (taxon_names.type = 'Combination' AND taxon_names.cached = ?))", o[1]) # see name.rb
            .pluck(:id, :cached, :cached_original_combination, :type)
            .each do |t|

              # references = reference_id_field(o)

              reified_id = ::Export::Coldp.reified_id(t[0], t[1], t[2])

              csv << [
                o[0],           # taxonID attached to the current valid concept
                reified_id,     # nameID
                nil,            # Status TODO def status(taxon_name_id)
                remarks_field,
                nil,            # Unclear what this means in TW
                o[3]            # TODO: remove after debuggin
              ]
            end
        end
    end
  end

  # It is unclear what the relationship beyond "used" means. We likely need a sensu style model to record these assertions
  # Export::Coldp::Files::Reference.add_reference_rows([], reference_csv) if reference_csv
end
