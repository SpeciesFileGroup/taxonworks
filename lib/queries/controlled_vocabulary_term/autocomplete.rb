module Queries
  module ControlledVocabularyTerm
    class Autocomplete < Query::Autocomplete

      # [Array]
      #   of :type 
      attr_accessor :type

      def initialize(string, **keyword_args)
        @query_string = string
        @project_id = keyword_args[:project_id]
        @type = keyword_args[:type] || []
      end

      def and_clauses
        clauses = [
          with_project_id,
          with_type
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def or_clauses
        clauses = [
          named,
          definition_matches,
          uri_equal_to,
          with_id
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end 

      # @return [Scope]
      def all 
        a = [or_clauses, and_clauses].compact 
        b = a.shift
        b = b.and(a.shift) if !a.empty?

        b.nil? ?
          ::ControlledVocabularyTerm.all.order(:type, :name).limit(40) :
          ::ControlledVocabularyTerm.where(b).order(:type, :name).limit(40) 
      end

      def table
        ::ControlledVocabularyTerm.arel_table
      end

      def keyword_named
        table[:name].matches_any(terms) if terms.any?
      end

      def with_type 
        table[:type].eq_any(type) if type.any?    
      end

      def uri_equal_to
        table[:uri].eq(query_string) if !query_string.blank?
      end

      def definition_matches
        table[:definition].matches_any(terms) if terms.any?
      end

    end
  end
end
