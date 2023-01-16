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

      attr_accessor :text # was query_string

      # @return [Boolean, nil]
      #   true - only content with depictions
      attr_accessor :depictions

      # @return [Boolean, nil]
      #   true - only content with citations
      attr_accessor :citations

      # @param [Hash] args
      def initialize(params)
        @topic_id = params[:topic_id]
        @otu_id = params[:otu_id]
      
        @text = params[:text]

        # TODO: use helper method
        @exact = (params[:exact]&.to_s&.downcase == 'true' ? true : false) if !params[:exact].nil?
        @depictions = (params[:depictions]&.to_s&.downcase == 'true' ? true : false) if !params[:depictions].nil?
        @citations = (params[:citations]&.to_s&.downcase == 'true' ? true : false) if !params[:citations].nil?

        set_user_dates(params)
      end

      def topic_id
        [@topic_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          text_facet,
          topic_id_facet,
          otu_id_facet,
          project_id_facet,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
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
      def project_id_facet
        return nil if project_id.empty?
        table[:project_id].eq_any(project_id)
      end

      # TODO: DRY depictions/citations

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
      def citations_facet
        return nil if citations.nil?
        if citations
          ::Content.joins(:citations)
        else
          ::Content.left_joins(:citations).where(citations: {id: nil})
        end
      end

      # @return [Arel::Node, nil]
      def topic_id_facet
        return nil if topic_id.empty?
        table[:topic_id].eq_any(topic_id)
      end

      def merge_clauses
        clauses = [
          depictions_facet,
          citations_facet,
          created_updated_facet, # See Queries::Concerns::Users
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        q = nil
        if a && b
          q = b.where(a)
        elsif a
          q = ::Content.includes(:otu, :topic).where(a)
        elsif b
          q = b
        else
          q = ::Content.includes(:otu, :topic).all
        end

        q
      end

    end

  end
end
