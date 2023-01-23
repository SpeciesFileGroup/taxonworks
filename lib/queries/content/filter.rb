module Queries
  module Content
    class Filter < Query::Filter

      include Queries::Concerns::Users

      # @return [Array]
      # @param topic_id [Array, Integer, String, nil]
      attr_accessor :topic_id

      # @return [Array]
      # @param otu_id [Array, Integer, String, nil]
      attr_accessor :otu_id

      # @return [Boolean, nil]
      attr_accessor :exact

      # @return [String, nil]
      #   text to match against 
      attr_accessor :text

      # @return [Boolean, nil]
      #   true - only Content with depictions
      #   false - only Content without depictions
      #   nil - any
      attr_accessor :depictions

      # @param [Hash] args
      def initialize(params)
        @depictions = boolean_param(params, :depictions)
        @exact = boolean_param(params, :exact)
        @otu_id = params[:otu_id]
        @text = params[:text]
        @topic_id = params[:topic_id]

        set_user_dates(params)
        super
      end

      def topic_id
        [@topic_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
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
      def depictions_facet
        return nil if depictions.nil?
        if depictions
          ::Content.joins(:depictions)
        else
          ::Content.left_joins(:depictions).where(depictions: {id: nil})
        end
      end

      # @return [Arel::Node, nil]
      def topic_id_facet
        return nil if topic_id.empty?
        table[:topic_id].eq_any(topic_id)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        [
          text_facet,
          topic_id_facet,
          otu_id_facet,
        ]
      end

      def merge_clauses
        [
          depictions_facet,
          citations_facet,
          origin_citation_facet,
        ]
     end
    end

  end
end
