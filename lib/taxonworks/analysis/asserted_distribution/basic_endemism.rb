module TaxonWorks
  module Analysis
    module AssertedDistribution
      module BasicEndemism

        # @param taxon_name [TaxonName] required
        # @param geographic_area [GeographicArea] required
        # @return [Hash]
        #    a very simple report summarizing asserted distributions
        #    !! only a single geographic area is used (not its children)
        def self.quick_endemism(taxon_name, geographic_area)
          data = {}

          otus =  Otu.descendant_of_taxon_name(taxon_name.id)
          return {} if otus.count > 2000

          q = ::Queries::AssertedDistribution::Filter.new(
            taxon_name_id: taxon_name.id,
            descendants: true,
            geographic_area: 
          )

          return {} if q.all.select(:otu_id).distinct.count > 2000

          q.all.find_each do |a|
           
            e = ::AssertedDistribution.where(project: taxon_name.project, otu_id: a.otu_id).where.not(geographic_area:).count
            
            n = a.otu.taxon_name&.valid_taxon_name

            if e == 0 && !data[n]
              data[n] = false
            else
              data[n] = true
            end
          end
          data
        end

      end
    end
  end
end
