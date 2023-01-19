module Queries
  module Extract

    class Filter < Query::Filter
      include Queries::Helpers
      include Queries::Concerns::Tags
      include Queries::Concerns::Protocols
      include Queries::Concerns::DateRanges

      PARAMS = [
        :ancestor_id,
        :collection_object_id,
        :exact_verbatim_anatomical_origin,
        :extract_end_date_range,
        :extract_origin,
        :extract_start_date_range,
        :id, # TODO `extract_id`
        :otu_id,
        :protocol_id,
        :recent, # TODO: likely out
        :repository_id,
        :sequences,
        :verbatim_anatomical_origin,
        collection_object_id: [],
        otu_id: [],
        repository_id: [],
      ].freeze

      # @return [Array of Repository#id]
      attr_accessor :repository_id

      # @return [Array of Repository#id]
      attr_accessor :otu_id

      # @return [Array of Repository#id]
      attr_accessor :collection_object_id

      # @return [Protonym.id, nil]
      #   return all extracts linked to OTUs AND CollectionObject that is self or descendant linked
      #   to this TaxonName
      attr_accessor :ancestor_id

      # @param extract_start_date_range [String]
      #  yyyy-mm-dd
      # @return [Date, nil]
      attr_accessor :extract_start_date_range

      # @param extract_end_date_range [String]
      #    yyyy-mm-dd
      # @return [Date, nil]
      attr_accessor :extract_end_date_range

      # @return [Boolean]
      # @param [String, Boolean, nil]
      attr_accessor :sequences

      # @return [String, nil]
      # @param [String]
      #   see originates_from in app/models/extract.rb for legal values
      attr_accessor :extract_origin

      # @return [String, nil]
      # @param anatomical_origin [String]
      attr_accessor :verbatim_anatomical_origin

      # @return [Boolean, nil]
      # @param extract_anatomical_origin [String]
      #    'true', 'false', nil
      attr_accessor :exact_verbatim_anatomical_origin

      # @param [Hash] args are permitted params
      def initialize(params)
        @ancestor_id = params[:ancestor_id]
        @collection_object_id = params[:collection_object_id]
        @exact_verbatim_anatomical_origin = params[:exact_verbatim_anatomical_origin]
        @extract_end_date_range = params[:extract_end_date_range]
        @extract_origin = params[:extract_origin]
        @extract_start_date_range = params[:extract_start_date_range]
        @otu_id = params[:otu_id]
        @repository_id = params[:repository_id]
        @sequences = boolean_param(params, :sequences)
        @verbatim_anatomical_origin = params[:verbatim_anatomical_origin]

        set_dates(params)
        set_tags_params(params)
        set_protocols_params(params)
        super
      end

      def repository_id
        [@repository_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def repository_id_facet
        return nil if repository_id.empty?
        table[:repository_id].eq_any(repository_id)
      end

      def otu_id_facet
        return nil if otu_id.empty?
        a = ::Extract.joins(:origin_otus).where(otus: {id: otu_id})
        b = ::Extract.joins(origin_collection_objects: [:otus]).where(otus: {id: otu_id})

        ::Extract.from("((#{a.to_sql}) UNION (#{b.to_sql})) as extracts")
      end

      def extract_origin_facet
        return nil if extract_origin.nil?
        ::Extract.joins(:related_origin_relationships).where(origin_relationships: {old_object_type: extract_origin})
      end

      def sequences_facet
        return nil if sequences.nil?

        subquery = ::OriginRelationship.where(
          ::OriginRelationship.arel_table[:old_object_id].eq(table[:id])
          .and(::OriginRelationship.arel_table[:new_object_type].eq('Sequence')))
          .arel.exists
        ::Extract.where(sequences ? subquery : subquery.not)
      end

      # TODO: Abstract to single date store range helper
      def date_made_facet
        return nil if extract_start_date_range.nil?
        a = extract_start_date_range
        sy,sm,sd = a.year, a.month, a.day
        b = extract_end_date_range
        ey,em,ed = b.year, b.month, b.day

        # 5 possible ranges to consider

        ranges = []

        if sy < ey
          # b/w years
          ranges.push table[:year_made].gt(sy).and(table[:year_made].lt(ey))

          # b/w months start
          ranges.push table[:year_made].eq(sy).and(table[:month_made].gt(sm))

          # b/w months end
          ranges.push table[:year_made].eq(ey).and(table[:month_made].lt(em))
        end

        # days in start month
        ranges.push table[:year_made].eq(sy).and(table[:month_made].eq(sm)).and(table[:day_made].gteq(sd)).and(table[:day_made].lteq(ed))

        # days in end month
        ranges.push table[:year_made].eq(ey).and(table[:month_made].eq(em)).and(table[:day_made].lteq(ed))

        a = ranges.shift
        ranges.each do |r|
          a = a.or(r)
        end
        a
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        ::Extract.joins(:origin_collection_objects).where(collection_objects: {id: collection_object_id})
      end

      # TODO: with()
      # TODO: this is not a join, but an IN x2 UNION, i.e. there
      # is likely room for optimization via a join.
      def ancestors_facet
        return nil if ancestor_id.nil?

        a = ::Extract.joins(:origin_otus).where(otus: ::Otu.descendant_of_taxon_name(ancestor_id))
        b = ::Extract.joins(:origin_collection_objects).where(collection_objects: ::CollectionObject.joins(:otus).where(otus: ::Otu.descendant_of_taxon_name(ancestor_id)) )

        ::Extract.from("((#{a.to_sql}) UNION (#{b.to_sql})) as extracts")
      end

      # !! Targets origins of *both* Otu, and Determined specimens
      def otu_query_facet
        return nil if otu_query.nil?
        w = 'WITH query_otu_exs_a AS (' + otu_query.all.to_sql + ') '

        u1 = ::Extract
          .joins(:origin_otus)
          .joins('JOIN query_otu_exs_a as query_otu_exs_a1 on otus.id = query_otu_exs_a1.id')
          .to_sql

        u2 = ::Extract
          .joins(origin_collection_objects: [:taxon_determinations])
          .joins('JOIN query_otu_exs_a as query_otu_exs_a2 on taxon_determinations.otu_id = query_otu_exs_a2.id')
          .where('taxon_determinations.position = 1')
          .to_sql

        s = w + ::Extract.from("((#{u1}) UNION (#{u2})) as extracts").to_sql

        ::Extract.from('(' + s + ') as extracts')
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_exs AS (' + collection_object_query.all.to_sql + ') ' +
          ::Extract
          .joins(:origin_collection_objects)
          .joins('JOIN query_co_exs as query_co_exs1 on collection_objects.id = query_co_exs1.id')
          .to_sql

        ::Extract.from('(' + s + ') as extracts')
      end

      # @return [Array]
      def and_clauses
        [
          repository_id_facet,
          date_made_facet,
          attribute_exact_facet(:verbatim_anatomical_origin),
        ]
      end

      def merge_clauses
        [
          source_query_facet,
          otu_query_facet,
          collection_object_query_facet,

          ancestors_facet,
          collection_object_id_facet,
          extract_origin_facet,
          otu_id_facet,
          sequences_facet,
        ]
      end

      private

      def extract_start_date_range
        return nil if @extract_start_date_range.nil?
        d = nil
        begin
          d = Date.parse(@extract_start_date_range)
        rescue Date::Error
        end
        d
      end

      def extract_end_date_range
        @extract_end_date_range ||= @extract_start_date_range
        return nil if @extract_end_date_range.nil?
        d = nil
        begin
          d = Date.parse(@extract_end_date_range)
        rescue Date::Error
        end
        d
      end

    end
  end
end
