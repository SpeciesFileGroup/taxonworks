# Is this OTU/OTU synonymy?!
# Technically this is Otu to Name
#   however in backend this is NameUsage : Name
#   
module Export::Coldp::Files::Synonym

  # We don't cover ICNCP?
  def self.generate(otus, reference_csv = nil)

    # @return String
    # Last 3 of http://api.col.plus/vocab/taxonomicstatus
    def self.status(o, t)
      #'synonym'
      #'ambiguous synonym'
      #'missaplied'

      'synonym' 
    end

    def self.remarks
      nil 
    end

    # taxonID - are all valid 
    # nameID - are all invalid

    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{taxonID nameID status remarks}

      otus.each do |o|
        next unless o.taxon_name && !o.taxon_name.is_valid?

        # This is an experiment
        synonym_type = Otu.where(taxon_name_id: o.taxon_name.cached_valid_taxon_name_id).size > 1 ? 'ambiguous synonym' : 'synonym'

        Otu.where(taxon_name_id: o.taxon_name.cached_valid_taxon_name_id).each do |votu|
          csv << [
            votu.id,
            o.taxon_name.id,
            synonym_type, # Todo def status(taxon_name_id)
            remarks, 
          ]
        end
      end

      # If we cite relationships then we add sources here (when CoL allows)
      # Export::Coldp::Files::Reference.add_reference_rows([], reference_csv) if reference_csv
    end
  end
end
