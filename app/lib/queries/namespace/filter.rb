module Queries
  module Namespace
    class Filter < Query::Filter

      PARAMS =  [
        :institution,
        :is_virtual,
        :name,
        :namespace_id,
        :short_name,
        :verbatim_name,
        namespace_id: [],
      ].freeze

      attr_accessor :namespace_id

      # @param institution [String]
      #   wildcarded to match institution
      attr_accessor :institution

      # @param name [Array, String]
      # @return [Array]
      attr_accessor :name

      # @param short_name [Array, String]
      # @return [Array]
      attr_accessor :short_name

      # @param verbatim_short_name [Array, String]
      # @return [Array]
      attr_accessor :verbatim_short_name

      # @return Boolean
      attr_accessor :is_virtual

      def initialize(query_params)
        super
        @institution = params[:institution]
        @is_virtual = boolean_param(params, :is_virtual)
        @name = params[:name]
        @namespace_id = params[:namespace_id]
        @short_name = params[:short_name]
        @verbatim_short_name = params[:verbatim_short_name]
      end

      def name
        [@name].flatten.compact
      end

      def namespace_id
        [@namespace_id].flatten.compact
      end

      def short_name
        [@short_name].flatten.compact
      end

      def verbatim_short_name
        [@verbatim_short_name].flatten.compact
      end

      def name_facet
        return nil if name.empty?
        table[:name].in(name)
      end

      def short_name_facet
        return nil if short_name.empty?
        table[:short_name].in(short_name)
      end

      def verbatim_name_facet
        return nil if verbatim_short_name.empty?
        table[:verbatim_short_name].in(verbatim_short_name)
      end

      def institution_facet
        return nil if institution.nil?
        table[:institution].matches('%' + insititution + '%')
      end

      def is_virtual_facet
        return nil if is_virtual.nil?
        table[:is_virtual].eq(is_virtual)
      end

      def and_clauses
        [
          institution_facet,
          is_virtual_facet,
          name_facet,
          short_name_facet,
          verbatim_name_facet,
        ]
      end

    end
  end
end
