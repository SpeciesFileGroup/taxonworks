module Queries
  module TaxonName 

    # Summarize data across a nomenclatural hierarchy.
    #  
    # The approach is to use OVER/PARTITION build ranked list, then to summarize only those ranked data requested.
    # When we select without preserving all ranks, then the data are not sortable according to their overall neesting.
    #
    # The approach only succeeds on the hierarchical data because we cache the current valid id for every name, this 
    # allows us to build an ordered, nested by hierarchy list across not only valid, but also combination and invalid names.
    #
    # These were useful references: 
    #   * https://sonnym.github.io/2017/06/05/common-table-expressions-in-activerecord-a-case-study-of-quantiles/
    #   * https://blog.codeship.com/folding-postgres-window-functions-into-rails/
    class Tabular < Queries::Query

      # @return [Integer]
      #   required, the id scoping the result set 
      attr_accessor :ancestor_id

      # @return [Array]
      #   like 'family', 'genus', 'species'
      # ORDER IS IMPORTANT
      attr_accessor :ranks

      # @return [Array]
      #   like 'family', 'genus', 'species'
      # ORDER IS IMPORTANT
      attr_accessor :rank_data

      # !! CAREFUL, too small limits will not properly nest all names !!
      attr_accessor :limit

      # @return [Boolean]
      #   if true than also include combinations
      attr_accessor :combinations

      # @return [Array of Strings]
      #  named sets of columns to include
      #  valid values are 
      #    - observations
      attr_accessor :fieldsets

      # @return [Boolean]
      #   if true then only include valid names
      attr_accessor :validity

      # Internal accessors 

      # @return [ the build query ] 
      attr_accessor :query
      
      attr_accessor :ancestor
      attr_accessor :data_fields
      attr_accessor :column_headers
      attr_accessor :rank_joins
      attr_accessor :rank_id_fields

      # @param params [Params] 
      #   a permitted via controller
      def initialize(params)
        super(nil, params)

        @ancestor_id = params[:ancestor_id]
        @combinations = (params[:combinations]&.downcase == 'true' ? true : false)
        @limit = params[:limit]
        @ranks = params[:ranks] || [] 
        @rank_data = params[:rank_data] || [] 
        @validity = (params[:validity]&.downcase == 'true' ? true : false)

        @ancestor = ::Protonym.where(project_id: project_id).find(ancestor_id)
        @column_headers = ['rank_over', 'otu_id', 'taxon_name_id', 'cached_valid_taxon_name_id', *ranks, 'cached'] 
        @fieldsets = params[:fieldsets] || []
        @rank_id_fields = []
        @rank_joins = []
        @data_fields = []

        build_query
      end

      def table
        ::TaxonName.arel_table
      end 

      def hierarchy_table
        Arel::Table.new(:taxon_name_hierarchies)
      end

      def otu_table
        ::Otu.arel_table
      end

      def base_query
        q = table
        h = hierarchy_table     

        # Scope all names in the result
        a = table[:id].eq(h[:descendant_id])
          .and(h[:ancestor_id].eq(ancestor_id) )
        a = a.and(table[:cached_valid_taxon_name_id].eq(table[:id])) if validity
       
        # Start a query 
        q = q.join(h, Arel::Nodes::InnerJoin).on(a)

        # All results can reference an otu
        q.join(otu_table, Arel::Nodes::OuterJoin).on(
          otu_table[:taxon_name_id].eq( table[:id] ).and( otu_table[:id].not_eq(nil)))
      end

      def build_query
        name_fields = {}

        q = base_query

        # Add a join to the valid parent_id 
        valid_table = table.alias('valid_taxon_names')
        q = q.join(valid_table, Arel::Nodes::InnerJoin).on(
          table[:cached_valid_taxon_name_id].eq(valid_table[:id])
        )

        # Setup the basic joins for each requested rank,
        # these are re-used in data gathering queries.
        ranks.each_with_index do |r, i|
          l = table.alias("j_#{i}")
          @rank_joins.push l 

          a = l[:id].eq(hierarchy_table[:descendant_id]) 
          a = a.and( l[:rank_class].eq( Ranks.lookup(ancestor.nomenclatural_code, ranks[i])) )

          q = q.join(l, Arel::Nodes::OuterJoin).on(a)

          name_fields[ ranks[i] ] = l[:name].as( ranks[i] )
          @rank_id_fields.push l[:id]
        end

        # add individual sets of data columns 
        fieldsets.each do |f|
          q = send(f + '_set', q) 
        end

        # scope the query to only specified ranks
        w = table[:rank_class].eq_any(rank_classes)
        w = w.or(table[:rank_class].eq(nil)) if combinations
       
        q = q.project(
          rank_over(table, valid_table), # the sort column
          otu_table[:id].as('otu_id'),        
          table[:id].as('taxon_name_id'),
          table[:cached_valid_taxon_name_id].as('cached_valid_taxon_name_id'),
          *name_fields.values,
          table[:cached].as('cached'),
          *data_fields,
        ).from(table).where(w).distinct

        # !! CAREFUL, too small limits will not properly nest all names !!
        q = q.take(limit.to_i) if limit

        @query = table.project( Arel::Nodes::SqlLiteral.new('*') ).from(q.as('p')).order( 'cached_valid_taxon_name_id', 'ro'  ) # if every field had a value this would work
      end

      def rank_classes
        ranks.collect{|r| Ranks.lookup(ancestor.nomenclatural_code, r)}
      end
      
      # @return t[:id] for the finest rank, t is aliased
      def finest_rank_id
        coalesce_ranks(rank_id_fields.reverse)
      end

      def coalesce_ranks(fields)
        Arel::Nodes::NamedFunction.new('coalesce', [fields])
      end

      # Lets us generate a sort order across valid, invalid, and combinations
      def rank_over(source_table, valid_source_table)
        Arel::Nodes::Over.new(
          Arel::Nodes::SqlLiteral.new('rank()'),
          Arel::Nodes::Window.new.partition(
            [ valid_source_table[:parent_id] ]
          ).order( source_table[:cached_valid_taxon_name_id], source_table[:cached], source_table[:name] )
        ).as('ro') 
      end 

      def all
        ApplicationRecord.connection.execute(@query.to_sql)
      end

      # TODO: break out fieldset to its own concern
      def observations_set(query)
        @data_fields.push '"fs_o1"."observation_count" as observation_count'
        @column_headers.push 'observation_count'
        o = ::Observation.arel_table
        x = o.project(
          o[:otu_id], 
          o[:otu_id].count.as('observation_count')
        ).group(o[:otu_id]).as('fs_o1')

        query.join(x, Arel::Nodes::OuterJoin).on(x[:otu_id].eq(otu_table[:id]))

        @data_fields.push '"fs_o2"."observation_depictions" as observation_depictions'
        @column_headers.push 'observation_depictions'
        p = ::Depiction.arel_table
        y = p.join(o, Arel::Nodes::OuterJoin).on(
          p[:depiction_object_id].eq(o[:otu_id])).where(p[:depiction_object_type].eq('Observation'))
          .project(
            p[:depiction_object_id], 
            p[:depiction_object_id].count.as('observation_depictions')
        ).group(p[:depiction_object_id]).as('fs_o2')

        query.join(y, Arel::Nodes::OuterJoin).on(y[:depiction_object_id].eq(otu_table[:id]))

        @data_fields.push '"fs_d1"."descriptors_scored" as descriptors_scored'
        @column_headers.push 'descriptors_scored'
        z = o.project(
          o[:otu_id], 
          o[:descriptor_id].count.as('descriptors_scored')
        ).group(o[:otu_id]).as('fs_d1')

        query.join(z, Arel::Nodes::OuterJoin).on(z[:otu_id].eq(otu_table[:id]))
      end

      # TODO: break out fieldset to its own concern
      def nomenclatural_stats_set(query)
        h = hierarchy_table
        t = table

        c = rank_data
        c << nil if combinations

        c.each_with_index do |r,i|
          %w{valid invalid}.each do |v|
            s = "#{v}_#{r ? r : 'combination' }"
            a = "ns_o#{i}_#{v}"
            @data_fields.push "\"#{a}\".\"#{s}\" as #{s}"
            @column_headers.push s

            x = t.where(
              h[:generations].gt(0) 
              .and( v == 'valid' ? t[:cached_valid_taxon_name_id].eq(t[:id]) : t[:cached_valid_taxon_name_id].not_eq(t[:id]) ) 
              .and( t[:rank_class].eq( Ranks.lookup(ancestor.nomenclatural_code, r) ) )
            )
              .join(h, Arel::Nodes::InnerJoin).on(
                h[:descendant_id].eq( t[:id] )  )
              .project(
                h[:ancestor_id],
                t[:id].count.as( s )
            ).group(h[:ancestor_id])
              .as(a)

            query.join(x, Arel::Nodes::OuterJoin).on( x[:ancestor_id].eq( finest_rank_id  ) )  # # NOT query['taxon_name_id']
          end
        end
        query
      end

    end
  end
end

# An alternate approach was explored, but it's overkill given our cached valid id:
#
# WITH RECURSIVE subordinates AS (
#    SELECT
#       id, 
#       parent_id,
#       rank_class,
#       name,
#       cached_valid_taxon_name_id,
#       cached 
#     FROM
#       taxon_names 
#    WHERE
#       id = 373809
#    UNION
#       SELECT
#          e.id,
#          e.parent_id,
#          e.rank_class,
#          e.name,
#          e.cached_valid_taxon_name_id,
#          e.cached
#       FROM
#          taxon_names e
#       INNER JOIN subordinates s ON s.id = e.parent_id
# ) SELECT
#    *
# FROM
#    subordinates
# order by cached_valid_taxon_name_id, cached, name
