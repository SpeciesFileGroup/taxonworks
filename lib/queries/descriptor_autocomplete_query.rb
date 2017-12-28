module Queries
    class DescriptorAutocompleteQuery < Queries::Query
      def where_sql
        with_project_id.and(or_clauses).to_sql
      end
  
      def or_clauses
        clauses = [
          named,
          short_named,
          with_id
        ].compact
  
        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end 
  
      def short_named
        table[:short_name].matches_any(terms)
      end
  
      def all
        Descriptor.where(where_sql)
      end
  
      def table
        Descriptor.arel_table
      end
    end
  end
  