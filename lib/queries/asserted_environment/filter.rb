module Queries
  module AssertedEnvironment
    class Filter < Query::Filter

      include Queries::Concerns::Tags
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes

      PARAMS = [
        :asserted_environment_id,
        :asserted_environment_object_id,
        :asserted_environment_object_type,
        :uri,
        :uri_exact,
        :uri_label,
        :uri_label_exact,

        asserted_environment_id: [],
        asserted_environment_object_id: [],
        asserted_environment_object_type: []
      ].freeze

      # @return [Array]
      attr_accessor :asserted_environment_id

      # @return [Array]
      attr_accessor :asserted_environment_object_id

      # @return [Array]
      attr_accessor :asserted_environment_object_type

      # @return [String]
      attr_accessor :uri

      # @return [Boolean, nil]
      attr_accessor :uri_exact

      # @return [String]
      attr_accessor :uri_label

      # @return [Boolean, nil]
      attr_accessor :uri_label_exact

      # @param params [Hash]
      def initialize(query_params)
        super

        @asserted_environment_id = params[:asserted_environment_id]
        @asserted_environment_object_id = params[:asserted_environment_object_id]
        @asserted_environment_object_type = params[:asserted_environment_object_type]
        @uri = params[:uri]
        @uri_exact = boolean_param(params, :uri_exact)
        @uri_label = params[:uri_label]
        @uri_label_exact = boolean_param(params, :uri_label_exact)

        set_citations_params(params)
        set_data_attributes_params(params)
        set_tags_params(params)
      end

      def asserted_environment_id
        [@asserted_environment_id].flatten.compact
      end

      def asserted_environment_object_id
        [@asserted_environment_object_id].flatten.compact
      end

      def asserted_environment_object_type
        [@asserted_environment_object_type].flatten.compact
      end

      def asserted_environment_id_facet
        return nil if asserted_environment_id.empty?
        table[:id].in(asserted_environment_id)
      end

      def asserted_environment_object_type_facet
        return nil if asserted_environment_object_type.empty?
        table[:asserted_environment_object_type].in(asserted_environment_object_type)
      end

      def asserted_environment_object_facet
        return nil if asserted_environment_object_type.length != 1 ||
          asserted_environment_object_id.empty?

        table[:asserted_environment_object_id]
          .in(asserted_environment_object_id).and(
            table[:asserted_environment_object_type]
              .eq(asserted_environment_object_type.first)
          )
      end

      def uri_facet
        return nil if uri.blank?

        if uri_exact
          table[:uri].eq(uri.strip)
        else
          table[:uri].matches('%' + uri.strip.gsub(/\s/, '%') + '%')
        end
      end

      def uri_label_facet
        return nil if uri_label.blank?

        if uri_label_exact
          table[:uri_label].eq(uri_label.strip)
        else
          table[:uri_label].matches('%' + uri_label.strip.gsub(/\s/, '%') + '%')
        end
      end

      def and_clauses
        [
          asserted_environment_id_facet,
          asserted_environment_object_type_facet,
          asserted_environment_object_facet,
          uri_facet,
          uri_label_facet
        ]
      end

    end
  end
end
