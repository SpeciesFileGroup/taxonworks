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

  def self.generate(otus, reference_csv = nil)
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{taxonID nameID status remarks referenceID}

      # unique = {}

      # Otus are valid and invalid
      otus.eager_load(:taxon_name)
        .joins(:taxon_name)
        .where.not(taxon_name_id: nil)
        .where('taxon_names.id = taxon_names.cached_valid_taxon_name_id')
        .find_each do |o|
      
          # next unless o.taxon_name_id && o.taxon_name.is_valid?

        name = o.taxon_name

        # data = ::Catalog::Nomenclature::Entry.new(name)
        # data.names.each do |t|

        # TODO: come back to this point
        # name.synonyms.where.not(id: name.id).each do |t|
        name.historical_taxon_names.that_is_invalid.each do |t|
          #  name.historical_taxon_names.each do |t| <- NO!?

          # NO LONGER:
          # not valid, not a combioantion
          # reified = !(t.is_valid? || t.is_combination?)
          id = t.reified_id # We don't want original combinations here!  <- NO!

          # next if unique[[o.id, id]] == s
          # unique[[o.id, id]] = true

          references = reference_id_field(o)

          csv << [
            o.id,                                             # taxonID attached to the current valid concept
            id,                                             # nameID TODO: discuss again: (not the original combination!, see old reified ID)
            nil,                                              # status TODO def status(taxon_name_id)
            remarks_field,
            references                                        # unclear what this means in TW
          ]
        end
      end
    end
  end

  # It is unclear what the relationship beyond "used" means. We likely need a sensu style model to record these assertions
  # Export::Coldp::Files::Reference.add_reference_rows([], reference_csv) if reference_csv
end
