module Queries
  module Content
    class Filter < Query::Filter

      include Queries::Concerns::Citations
      include Queries::Concerns::Depictions

      PARAMS = [
        :exact,
        :text,
        :topic_id,
        :otu_id,
        :content_id,
        topic_id: [],
        otu_id: [],
        content_id: [],
      ].freeze

      # @return [Boolean, nil]
      attr_accessor :exact

      # @return [Array]
      # @param otu_id [Array, Integer, String, nil]
      attr_accessor :otu_id

      # @return [Array]
      # @param topic_id [Array, Integer, String, nil]
      attr_accessor :topic_id

      # @return [String, nil]
      #   text to match against
      attr_accessor :text

      # @param [Hash] args
      def initialize(query_params)
        super
        @exact = boolean_param(params, :exact)
        @otu_id = params[:otu_id]
        @text = params[:text]
        @topic_id = params[:topic_id]
        @content_id = params[:content_id]

        set_citations_params(params)
        set_depiction_params(params)
      end

      def topic_id
        [@topic_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def content_id
        [@content_id].flatten.compact
      end

      # @return [Arel::Node, nil]
      def text_facet
        return nil if text.blank?
        if exact
          table[:text].eq(text.strip)
        else
          table[:text].matches('%' + text.strip.gsub(/\s+/, '%') + '%')
        end
      end

      # @return [Arel::Node, nil]
      def otu_id_facet
        return nil if otu_id.empty?
        table[:otu_id].eq_any(otu_id)
      end

      # @return [Arel::Node, nil]
      def content_id_facet
        return nil if content_id.empty?
        table[:id].eq_any(content_id)
      end

      # @return [Arel::Node, nil]
      def topic_id_facet
        return nil if topic_id.empty?
        table[:topic_id].eq_any(topic_id)
      end

      def otu_query_facet
        return nil if otu_query.nil?

        s = 'WITH query_otu_con AS (' + otu_query.all.to_sql + ') ' +
          ::Content
          .joins('JOIN query_otu_con as query_otu_con1 on contents.otu_id = query_otu_con1.id')
          .to_sql

        ::Content.from('(' + s + ') as contents')
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?

        s = 'WITH query_tn_con AS (' + taxon_name_query.all.to_sql + ') ' +
          ::Content
          .joins(otu: [:taxon_name])
          .joins('JOIN query_tn_con as query_tn_con1 on taxon_names.id = query_tn_con1.id')
          .to_sql

        ::Content.from('(' + s + ') as contents')
      end

      def and_clauses
        [
          content_id_facet,
          otu_id_facet,
          text_facet,
          topic_id_facet,
        ]
      end

      def merge_clauses
        [
          otu_query_facet,
          taxon_name_query_facet,
        ]
      end
    end

  end
end
