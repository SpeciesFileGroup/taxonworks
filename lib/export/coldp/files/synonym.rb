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

    CSV.generate do |csv|
      otus.each do |o|
        o.taxon_name.self_and_descendants.that_is_invalid.each do |t|
          csv << [
            o.id,
            t.id,
            status(o,t), 
            remarks, 
          ]
        end
      end

      # If we cite relationships then we add sources here (when CoL allows)
      # Export::Coldp::Files::Reference.add_reference_rows([], reference_csv) if reference_csv
    end
  end
end
