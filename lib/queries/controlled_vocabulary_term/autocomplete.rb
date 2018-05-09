module Queries

  class ControlledVocabularyTerm::Autocomplete < Queries::Query

    # [Array]
    #   of :type 
    attr_accessor :of_type

    def initialize(string, project_id: nil, of_type: [])
      super(string, project_id: project_id) 
      @of_type = of_type
    end

    def where_sql
      c = [or_clauses]
      c.push with_project_id if !project_id.blank?
      c.push with_type if !of_type.blank?

      c.compact

      a = c.pop
      c.each do |q|
        a.and(q)
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

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end 
   
    # @return [Scope]
    def all 
      ::ControlledVocabularyTerm.where(where_sql).order(:type, :name).limit(40)
    end

    def table
      ::ControlledVocabularyTerm.arel_table
    end

    def keyword_named
      table[:name].matches_any(terms)
    end

    def with_type 
      table[:type].eq_any(of_type)
    end

    def uri_equal_to
      table[:uri].eq(query_string)
    end

    def definition_matches
      table[:definition].matches_any(terms)
    end

    # not used
    def uri_eq
      table[:uri].eq(query_string) 
    end

  end
end
