module Queries

  class ControlledVocabularyTermAutocompleteQuery < Queries::Query
    include Arel::Nodes

    attr_accessor :object_type

    def initialize(string, project_id: nil, object_type: nil)
      super(string, project_id: project_id) 
      @object_type = object_type
    end

    def where_sql
      with_project_id.and(with_type).and(or_clauses).to_sql
    end

    def or_clauses
      clauses = [
        named,
        definition_matches,
        uri_equal_to,
        with_id
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end 
    
    # @return [Scope]
    def all 
      ControlledVocabularyTerm.where(where_sql).limit(50)
    end

    def table
      ControlledVocabularyTerm.arel_table
    end

    def keyword_named
      table[:name].matches_any(terms)
    end

    def with_type 
      table[:type].eq(object_type)
    end

    def uri_equal_to
      table[:uri].eq(query_string)
    end

    def definition_matches
      table[:definition].matches_any(terms)
    end

    def uri_matches
      table[:uri].eq(query_string) 
    end

  end
end
