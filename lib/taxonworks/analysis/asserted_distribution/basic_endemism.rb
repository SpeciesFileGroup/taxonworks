module TaxonWorks
  module Analysis
    module AssertedDistribution
      module BasicEndemism

        # @param taxon_name [TaxonName] required
        # @param asserted_distribution_shape_type [String] required
        # @param asserted_distribution_shape_id [Integer] required
        # @return [Hash]
        #    a very simple report summarizing asserted distributions
        #    !! only a single shape is used (not its children)
        def self.quick_endemism(taxon_name,
          asserted_distribution_shape_type, asserted_distribution_shape_id
        )
          data = {}

          otus =  Otu.descendant_of_taxon_name(taxon_name.id)
          return {} if otus.count > 2000

          q = ::Queries::AssertedDistribution::Filter.new(
            taxon_name_id: taxon_name.id,
            descendants: true,
            asserted_distribution_shape_type:,
            asserted_distribution_shape_id:
          )

          return {} if q.all.select(:otu_id).distinct.count > 2000

          q.all.find_each do |a|

            e = ::AssertedDistribution
              .where(project: taxon_name.project, otu_id: a.otu_id)
              .where(asserted_distribution_shape_type:)
              .where.not(asserted_distribution_shape_id:).count

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
