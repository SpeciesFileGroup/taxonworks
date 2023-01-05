module Queries
  module CommonName
    class Filter < Query::Filter

      # Query variables
      attr_accessor :name, :geographic_area_id, :otu_id, :language_id

      # @param options [Hash]
      def initialize(options)
        @name = options[:name]
        @geographic_area_id = options[:geographic_area_id]
        @otu_id = options[:otu_id]
        @language_id = options[:language_id]
      end

      def table
        ::CommonName.arel_table
      end

      def matching_otu_id
        otu_id ? table[:otu_id].eq(otu_id) : nil
      end

      def matching_language_id
        language_id ? table[:language_id].eq(language_id) : nil
      end

      def matching_name
        name ? table[:name].eq(name) : nil
      end

      def matching_geographic_area_id
        geographic_area_id ? table[:geographic_area_id].eq(geographic_area_id) : nil
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          matching_otu_id,
          matching_geographic_area_id,
          matching_name,
          matching_language_id
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        if a
          ::CommonName.where(a).distinct
        else
          ::CommonName.none
        end
      end

    end
  end
end
