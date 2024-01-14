module Queries
  module Extract

    class Filter < Query::Filter
      include Queries::Concerns::Citations
      include Queries::Concerns::Containable
      include Queries::Concerns::DateRanges
      include Queries::Concerns::Protocols
      include Queries::Concerns::Tags
      include Queries::Helpers

      PARAMS = [
        :collection_object_id,
        :descendants,
        :exact_verbatim_anatomical_origin,
        :extract_end_date_range,
        :extract_id,
        :extract_origin,
        :extract_start_date_range,
        :otu_id,
        :protocol_id,
        :repository_id,
        :sequences,
        :taxon_name_id,
        :verbatim_anatomical_origin,
        collection_object_id: [],
        extract_id: [],
        otu_id: [],
        repository_id: [],
        taxon_name_id: [],
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
      attr_accessor :taxon_name_id
      attr_accessor :descendants

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

      # @return Array
      # @param extract_id [Numeric, String, Array]
      #   a set of extract#id
      attr_accessor :extract_id

      # @param [Hash] args are permitted params
      def initialize(query_params)
        super

        @collection_object_id = params[:collection_object_id]
        @descendants = boolean_param(params, :descendants)
        @exact_verbatim_anatomical_origin = params[:exact_verbatim_anatomical_origin]
        @extract_end_date_range = params[:extract_end_date_range]
        @extract_origin = params[:extract_origin]
        @extact_id = params[:extract_id]
        @extract_start_date_range = params[:extract_start_date_range]
        @otu_id = params[:otu_id]
        @repository_id = params[:repository_id]
        @sequences = boolean_param(params, :sequences)
        @taxon_name_id = params[:taxon_name_id]
        @verbatim_anatomical_origin = params[:verbatim_anatomical_origin]

        set_containable_params(params)
        set_citations_params(params)
        set_date_params(params)
        set_tags_params(params)
        set_protocols_params(params)
      end

      def extract_id
        [@extract_id].flatten.compact
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

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def extract_id_facet
        return nil if extract_id.empty?
        table[:id].in(extract_id)
      end

      def repository_id_facet
        return nil if repository_id.empty?
        table[:repository_id].in(repository_id)
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
      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        o = nil
        if descendants
          o = ::Otu.descendant_of_taxon_name(taxon_name_id)
        else
          o = ::Otu.where(taxon_name_id:)
        end

        a = ::Extract.joins(:origin_otus).where(otus: o)
        b = ::Extract.joins(:origin_collection_objects).where(collection_objects: ::CollectionObject.joins(:otus).where(otus: o))

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


      def observation_query_facet
        return nil if observation_query.nil?
        s = 'WITH query_obs_extracts AS (' + observation_query.all.to_sql + ') ' +
            ::Extract
              .joins(:observations)
              .joins('JOIN query_obs_extracts as query_obs_extracts1 on observations.id = query_obs_extracts1.id')
              .to_sql

        ::Extract.from('(' + s + ') as extracts').distinct
      end

      # @return [Array]
      def and_clauses
        [
          extract_id_facet,
          attribute_exact_facet(:verbatim_anatomical_origin),
          date_made_facet,
          repository_id_facet,
        ]
      end

      def merge_clauses
        [
          observation_query_facet,
          collection_object_query_facet,
          otu_query_facet,

          collection_object_id_facet,
          extract_origin_facet,
          otu_id_facet,
          sequences_facet,
          taxon_name_id_facet,
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
