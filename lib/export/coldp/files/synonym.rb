# Is this OTU/OTU synonymy?!
# Technically this is Otu to Name
#   however in backend this is NameUsage : Name
#   
module Export::Coldp::Files::Synonym

  # We don't cover ICNCP?
  def self.generate(otus, reference_csv = nil)

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

    # taxonID - are all valid 
    # nameID - are all invalid

    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{taxonID nameID status remarks referenceID}

      otus.each do |o|
        next unless o.taxon_name && !o.taxon_name.is_valid?

        # This is an experiment
        synonym_type = Otu.where(taxon_name_id: o.taxon_name.cached_valid_taxon_name_id).size > 1 ? 'ambiguous synonym' : 'synonym'

        # Coordinated?!
        Otu.where(taxon_name_id: o.taxon_name.cached_valid_taxon_name_id).each do |votu|

          references = reference_id_field(votu)

          csv << [
            votu.id,
            o.taxon_name.id,
            synonym_type, # Todo def status(taxon_name_id)
            remarks_field, 
            references
          ]

          if !Export::Coldp.original_field(o.taxon_name)
            csv << [
              votu.id,
              ::Export::Coldp.current_taxon_name_id(o.taxon_name), 
              synonym_type, # Todo def status(taxon_name_id)
              remarks_field, 
              references,
            ]
          end
        end


      end

      # If we cite relationships then we add sources here (when CoL allows)
      # Export::Coldp::Files::Reference.add_reference_rows([], reference_csv) if reference_csv
    end
  end
end
