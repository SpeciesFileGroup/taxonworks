module Queries
  module TaxonName 

    # Sumamrize nomenclature across specific ranks. 
    class Tabular < Queries::Query

      attr_accessor :ancestor_id

      attr_accessor :ancestor

      # @return [ query execution result ]
      attr_accessor :query

      # @return [Array]
      #   like 'family', 'genus', 'species
      # ORDER IS IMPORTANT
      attr_accessor :ranks

      # @param params [Params] 
      #   a permitted via controller
      def initialize(params)
        super(nil, params)
       
        @ranks = params[:ranks] 
        @ancestor_id = params[:ancestor_id]
        @ancestor = ::Protonym.where(project_id: project_id).find(ancestor_id)
      
        build_query
      end

      # @return [Arel::Table]
      def table
        ::TaxonName.arel_table
      end 

      def hierarchy_table
        Arel::Table.new(:taxon_name_hierarchies)
      end

      def otu_table
        ::Otu.arel_table
      end

      def build_query
        h = hierarchy_table

        a = table.alias('a')
        b = table.alias('b')
        c = table.alias('c')

        q = h.where(h[:ancestor_id].eq(ancestor_id))

        fields = {}
        fields2 = [] 

        [a,b,c].each_with_index do |t, i|
          if ranks[i]
            q = q.join(t, Arel::Nodes::OuterJoin)
              .on(t[:id].eq(h[:descendant_id]).
                  and(t[:rank_class].eq( Ranks.lookup(ancestor.nomenclatural_code, ranks[i]))))

            fields[ ranks[i]] = t[:name].as( ranks[i] )
            fields2.push t[:id]
          end
        end

        fields2.reverse!

        q = q.join(otu_table, Arel::Nodes::OuterJoin).on(otu_table[:taxon_name_id].eq( coalesce_ranks(fields2) )) 

        projected_fields = [
          h[:generations].as('generations'), 
          otu_table[:id].as('otu_id'),
          coalesce_ranks(fields2).as('taxon_name_id'),
          coalesce_ranks([c[:cached], b[:cached], a[:cached]]).as('cached'),
          fields.values
        ]

        @query = q.distinct.take(100).project( *projected_fields )
          .order(h[:generations], *fields.keys)
      end

      def column_headers
         ['generations', 'otu_id', 'taxon_name_id', 'cached'] + ranks 
      end

      def coalesce_ranks(fields)
        Arel::Nodes::NamedFunction.new('coalesce', [fields])
      end

      def projected_fields
      end

      def all
        ApplicationRecord.connection.execute(@query.to_sql)
      end

    end
  end
end
