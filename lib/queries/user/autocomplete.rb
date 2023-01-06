module Queries
  module User
   class Autocomplete < Query::Autocomplete

    # @return [Scope]
    def where_sql
      or_clauses.to_sql
    end

    # @return [Scope]
    def or_clauses
      clauses = [
        named,
        with_email,
        with_id
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end

    # @return [Arel::Nodes::Matches]
    def with_email
      table[:email].matches_any(terms) if terms.any?
    end

    # @return [Scope]
    def autocomplete 
      # For reference, this is equivalent: Otu.eager_load(:taxon_name).where(where_sql)
      ::User.where(where_sql).order(name: :asc)
    end

  end
end
