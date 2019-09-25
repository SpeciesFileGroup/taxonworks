# IS THIS OTU/OTU synonymy?!
# Technically this is Otu to Name
#   however in backend this is NameUsage : Name
module Export::Coldp::Files::Synonym

    CSV.generate do |csv|
      otus.each do |o|

        # description
        o.contents.each do |c|
        end
  
        # name
        otu.taxon_name.descendants.each do |t|
        end
     
        # synonym
        o.taxon_name.self_and_descendants.that_is_invalid.each do |t|
        end
      
        # taxon
         otu.sources.pluck(:id)
       
        # vernacular_names
         o.common_names.each do |n|
         end

      end
    end
  end
end

