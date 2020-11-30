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

      # reddis?
      unique = {}

      # otus are valid and invalid
      
      otus.each do |o| 
        next unless o.taxon_name && o.taxon_name.is_valid?

        name = o.taxon_name
        data = ::Catalog::Nomenclature::Entry.new(name)

        data.names.each do |t|
          # not valid, not a combioantion
          # reified = !(t.is_valid? || t.is_combination?)
          id = t.reified_id

          next if unique[[o.id, id]] == true

          unique[[o.id, id]] = true

          references = reference_id_field(o)
          csv << [
            o.id,                                             # taxonID attached to the current valid concept
            id,                                               # nameID
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
