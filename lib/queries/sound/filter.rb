module Queries
  module Sound
    class Filter < Query::Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations

      PARAMS = [
        :conveyance_object_type,
        :conveyances,
        :sound_id,
        :otu_id,
        :field_occurrence,

        field_occurrence_id: [],
        collection_object_id: [],
        conveyance_object_type: [],
        sound_id: [],
        otu_id: [],
      ].freeze

      # @return [Array]
      attr_accessor :collection_object_id

      # @return [Array]
      attr_accessor :field_occurrence_id

      # @return [Boolean, nil]
      #   true - sound is used (in a conveyance)
      #   false - sound is not used
      #   nil - either
      attr_accessor :conveyances

      # @return [Array]
      # @param conveyance_object_type
      #   one or more names of classes.
      attr_accessor :conveyance_object_type

      # @return [Array]
      attr_accessor :otu_id

      # @return [Array]
      attr_accessor :sound_id

      # @param params [Hash]
      def initialize(query_params)
        super

        @collection_object_id = params[:collection_object_id]
        @field_occurrence_id = params[:field_occurrence_id]
        @conveyance_object_type = params[:conveyance_object_type]
        @conveyances = boolean_param(params, :conveyances)
        @sound_id = params[:sound_id]
        @otu_id = params[:otu_id]

        set_citations_params(params)
        set_tags_params(params)
      end

      def sound_id
        [@sound_id].flatten.compact
      end

      def conveyance_object_type
        [@conveyance_object_type].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def field_occurrence_id
        [@field_occurrence_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      # @return [Arel::Table]
      def otu_table
        ::Otu.arel_table
      end

      # @return [Arel::Table]
      def collection_object_table
        ::CollectionObject.arel_table
      end

      # @return [Arel::Table]
      def field_occurrence_table
        ::FieldOccurrence.arel_table
      end

      # @return [Arel::Table]
      def conveyance_table
        ::Conveyance.arel_table
      end

      def conveyance_object_type_facet
        return nil if conveyance_object_type.empty?
        ::Sound.joins(:conveyances).where(conveyances: {conveyance_object_type:})
      end

      def conveyances_facet
        return nil if conveyances.nil?
        if conveyances
          ::Sound.joins(:conveyances)
        else
          ::Sound.where.missing(:conveyances)
        end
      end

      def otu_id_facet
        return nil if otu_id.empty?

        ::Sound.joins(:otus).where(otus: {id: otu_id})
      end

      def collection_object_facet
        return nil if collection_object_id.empty?

        ::Sound.joins(:collection_objects).where(collection_objects: {id: collection_object_id})
      end

      def field_occurrence_facet
        return nil if field_occurrence_id.empty?

        ::Sound.joins(:field_occurrences).where(field_occurrences: {id: field_occurrence_id})
      end

      def query_facets_facet(name = nil)
        return nil if name.nil?

        q = send((name + '_query').to_sym)

        return nil if q.nil?

        n = "query_#{name}_img"

        s = "WITH #{n} AS (" + q.all.to_sql + ') ' +
          ::Sound
          .joins(:conveyances)
          .joins("JOIN #{n} as #{n}1 on conveyances.conveyance_object_id = #{n}1.id AND conveyances.conveyance_object_type = '#{name.treetop_camelize}'")
          .to_sql

        ::Sound.from('(' + s + ') as sounds').distinct
      end

      def merge_clauses
        s = ::Queries::Query::Filter::SUBQUERIES.select{|k,v| v.include?(:sound)}.keys.map(&:to_s) - ['source']
        [
          *s.collect{|m| query_facets_facet(m)}, # Reference all the Sound referencing SUBQUERIES
          conveyance_object_type_facet,
          conveyances_facet,
          otu_id_facet,
          collection_object_facet,
          field_occurrence_facet
        ]
      end

    end
  end
end
