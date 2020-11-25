module Queries
  module Content
    class Filter 
      include Arel::Nodes

      # @return [Array]
      # @param topic_id [Array, Integer, String, nil]
      attr_accessor :topic_id

      # @return [Array]
      # @param otu_id [Array, Integer, String, nil]
      attr_accessor :otu_id

      attr_accessor :text # was query_string

      # attr_accessor :most_recent_updates

      # @param [Hash] args
      def initialize(params)

        # topic_id: nil, otu_id: nil, hours_ago: nil, query_string: nil, most_recent_updates: nil

        @topic_id = params[:topic_id]
        @otu_id = params[:otu_id]
        @text = params[:text]

       # @hours_ago = hours_ago.to_i if hours_ago
       # @most_recent_updates = most_recent_updates.to_i
      end

      def topic_id
        [@topic_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      # @return [Arel::Table]
      def table
        ::Content.arel_table
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          text_facet,
          topic_id_facet,
          otu_id_facet
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def text_facet
        text.blank? ? nil : table[:text].eq(text) 
      end

      # @return [Arel::Node, nil]
      def otu_id_facet
        return nil if otu_id.empty?
        table[:otu_id].eq_any(otu_id) 
      end

      # @return [Arel::Node, nil]
      def topic_id_facet
        return nil if topic_id.empty?
        table[:topic_id].eq_any(topic_id) 
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Content.includes(:otu, :topic).where(and_clauses)
        else
          ::Content.includes(:otu, :topic).all
        end
      end

      # @return [Arel::Nodes::Equatity]
      def recent
        table[:updated_at].gt(hours_ago.hours.ago) if hours_ago
      end
    end

  end
end
