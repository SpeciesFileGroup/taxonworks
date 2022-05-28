module Queries
  module TaxonName

    # Summarize data across a nomenclatural hierarchy.
    #
    # Results are Arrays, not AR objects.
    #
    # The approach is to use OVER/PARTITION to build a ranked list, then to summarize only those ranked data requested.
    # When we select without preserving all ranks, then the data are not sortable according to their overall nesting.
    #
    # The approach only succeeds on the hierarchical data because we cache the current valid id for every name, this
    # allows us to build an ordered, nested by hierarchy list across not only valid, but also combination and invalid names.
    #
    # These were useful references:
    #   * https://sonnym.github.io/2017/06/05/common-table-expressions-in-activerecord-a-case-study-of-quantiles/
    #   * https://blog.codeship.com/folding-postgres-window-functions-into-rails/
    class Tabular < Queries::Query

      include Queries::Helpers

      # @return [Integer]
      #   required, the id scoping the result set
      attr_accessor :ancestor_id

      # @return [Array]
      #   like 'family', 'genus', 'species'
      # ORDER matters
      attr_accessor :ranks

      # @return [Array]
      #   like 'family', 'genus', 'species'
      # ORDER MATTERS
      attr_accessor :rank_data

      # !! CAREFUL, too small limits will not properly nest all names !!
      #   defaults to 1000
      attr_accessor :limit

      # @return [Boolean]
      #   if true than also include Combinations in counts
      attr_accessor :combinations

      # @return [Array of Strings]
      #  named sets of columns to include
      #  valid values are
      #    - nomenclatural_stats
      #    - observations
      attr_accessor :fieldsets

      # @return [Boolean]
      #   if true then only include valid names
      attr_accessor :validity

      ### Internal 

      # @return [ the build query ]
      attr_accessor :query

      # @return [Protonym, nil]
      attr_accessor :ancestor

      attr_accessor :rank_id_fields

      # @return [Array]
      #   of hashes, with name of column, and SQL field projection definition
      #      { header: 'foo'
      #       projected: 'taxon_names.id'  }
      attr_accessor :columns

      # @param params [Hash]
      #   keys are symbols
      def initialize(params = {})
        super(nil, project_id: params[:project_id]) # We don't actually use project_id here

        @ancestor_id = params[:ancestor_id]
        @combinations = boolean_param(params, :combinations)
        @limit = params[:limit]
        @ranks = params[:ranks]
        @rank_data = params[:rank_data]
        @validity = boolean_param(params, :validity)
        @fieldsets = params[:fieldsets]
        @rank_id_fields = []

        initialize_columns
        build_query
      end

      # These are generic headers used for existing queries, ultimately subclass this with
      # a reference to core, if it can be abstracted as such
      def initialize_columns
        @columns = []
        valid_table = table.alias('valid_taxon_names')

        @columns.push({ header: 'ro', projected: rank_over(table, valid_table) })

        @columns.push({header: 'taxon_name_id', projected: table[:id].as('taxon_name_id') } )
        @columns.push({header: 'cached_valid_taxon_name_id', projected: table[:cached_valid_taxon_name_id].as('cached_valid_taxon_name_id') } )
        @columns.push({header: 'cached', projected: table[:cached].as('cached') } )

        if fieldsets.include?('observations')
          @columns.push({header: 'otu_id', projected: otu_table[:id].as('otu_id')  } )
          @columns.push({header: 'otu_name', projected:  otu_table[:name].as('otu_name')} )
        end
      end

      def fieldsets=(array)
        @fieldsets = array
        initialize_columns
      end

      def fieldsets
        [@fieldsets].flatten.compact
      end

      def column_headers
        columns.collect{|c| c[:header]}
      end

      def projected_columns
        columns.collect{|c| c[:projected]}
      end

      def ranks
        [@ranks].flatten.compact
      end

      def rank_data
        [@rank_data].flatten.compact
      end

      def ancestor
        return nil unless ancestor_id
        @ancestor ||= ::Protonym.find(ancestor_id)
      end

      def limit
        @limit ||= 1000
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

        # TODO: not always true now
        # All results can reference an otu
        q.join(otu_table, Arel::Nodes::OuterJoin).on(
          otu_table[:taxon_name_id].eq( table[:id] ).and( otu_table[:id].not_eq(nil)))
      end

      def build_query
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

          a = l[:id].eq(hierarchy_table[:descendant_id])
          a = a.and( l[:rank_class].eq( Ranks.lookup(ancestor.nomenclatural_code, ranks[i])) )

          q = q.join(l, Arel::Nodes::OuterJoin).on(a)

          @columns.push( {header: r, projected:  l[:name].as( ranks[i] )  } )

          @rank_id_fields.push l[:id]
        end

        # add individual sets of data columns
        fieldsets.each do |f|
          q = send(f + '_set', q)
        end

        # TODO: rank_classes getter should merge nil when combinations,
        # i.e. we likely don't need nil
        w = table[:rank_class].eq_any(rank_classes)
        w = w.or(table[:rank_class].eq(nil)) if combinations

        q = q.project(*projected_columns)
        q = q.from(table).where(w).distinct
        q = q.take(limit.to_i) if limit

        @query = table.project( Arel::Nodes::SqlLiteral.new('*') ).from(q.as('p')).order( 'cached_valid_taxon_name_id', 'ro' ) # if every field had a value this would work
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

      # Only calculates for OTUs, not through to 
      # get CollectionObjects, nor Extracts
      def observations_set(query)
        o = ::Observation.arel_table

        # Observations on OTUs
        f = 'otu_observation_count'
        fa = 'fs_o1'
        @columns.push({header: f, projected: '"' + fa +  '"."' + f + '" as ' + f })

        x = o.project(
          o[:observation_object_id],
          o[:observation_object_type],
          o[:id].count.as(f)
        ).group(o[:observation_object_id], o[:observation_object_type]).as(fa)

        query.join(x, Arel::Nodes::OuterJoin).on(x[:observation_object_id].eq(otu_table[:id]).and( x[:observation_object_type].eq('Otu')  ))

        # Depictions on observations on OTUs
        f = 'otu_observation_depictions'
        fa = 'fs_o2'
        @columns.push( {header: f, projected: '"' + fa + '"."' + f + '" as ' + f } )

        p = ::Depiction.arel_table
        y = o.join(p, Arel::Nodes::InnerJoin).on(
          o[:id].eq(p[:depiction_object_id]).and(
            p[:depiction_object_type].eq('Observation')
          )
        ).project(
          o[:observation_object_id], # an OTU id
          p[:depiction_object_type],
          p[:id].count.as(f)
        ).group(
          o[:observation_object_id],
          p[:depiction_object_type]
        ).as(fa)

        query.join(y, Arel::Nodes::OuterJoin).on(
          y[:observation_object_id].eq(otu_table[:id])
        )

        # Descriptors on OTUs scored
        f = 'descriptors_scored_for_otus'
        fa = 'fs_d1'
        @columns.push({header: f, projected: '"' + fa + '"."' + f + '" as ' + f } )

        z = o.project(
          o[:observation_object_id],
          o[:observation_object_type],
          o[:descriptor_id].count(true).as(f) # count(true) == distinct
        ).group(
          o[:observation_object_id],
          o[:observation_object_type],
        ).as(fa)

        query.join(z, Arel::Nodes::OuterJoin).on(
          z[:observation_object_id].eq(otu_table[:id])
          .and(z[:observation_object_type].eq('Otu'))
        )
        query
      end

      def nomenclatural_stats_set(query)
        c = rank_data

        i = 0
        c.each do |r|
          %w{valid invalid}.each do |v|
            nomenclature_stats_column(query, r, v, i)
            i += 1
          end
        end

        nomenclature_stats_column(query, 'combination', nil, i)

        query
      end

      def nomenclature_stats_column(query, rank, valid = nil, index = 0)
        i = index
        v = valid
        r = rank

        h = hierarchy_table

        # May be alias?
        t = table

        s = [v, r].compact.join('_')
        a = ['ns_o', r, i, v].join('_')
        @columns.push({header: s, projected: "\"#{a}\".\"#{s}\" as #{s}" })

        x = t.where(
          # h[:generations].gt(0)
          t[:cached_is_valid].eq( v == 'valid' ? true : false )
          .and( t[:rank_class].eq( Ranks.lookup(ancestor.nomenclatural_code, r) ) )
        ).join(h, Arel::Nodes::InnerJoin).on(

          h[:descendant_id].eq( t[:cached_valid_taxon_name_id] )  ) # h[:descendant_id].eq( t[:id] ) )
          .project(
            h[:ancestor_id],
            t[:id].count.as( s )
          ).group(h[:ancestor_id]) # TODO: Might be wrong
            .as(a)

          query.join(x, Arel::Nodes::OuterJoin).on( x[:ancestor_id].eq( finest_rank_id  ))
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
