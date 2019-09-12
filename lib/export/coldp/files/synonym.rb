# IS THIS OTU/OTU synonymy?!
# Technically this is Otu to Name
#   however in backend this is NameUsage : Name
module Export::Coldp::Files::Synonym

  # We don't cover ICNCP?
  def self.generate(otus)

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
    end
  end
end

