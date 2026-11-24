module Match
  module Source
    class Field

      # The DOI. DOIs are stored canonically as Identifier::Global::Doi
      # (Source#doi reads from there, the doi column is not normalized), and
      # compared lowercased.
      class Doi < Field

        NORMALIZED_SQL = 'lower(trim(identifiers.identifier))'.freeze

        # @return [ActiveRecord::Relation] DOI identifiers of Sources
        def self.identifiers
          ::Identifier::Global::Doi.where(identifier_object_type: 'Source')
        end

        # @param dois [Array<String>] lowercased
        # @param scope [ActiveRecord::Relation] the identifiers to look in
        # @return [Hash] doi => [source_id, ...]
        def self.source_ids_by_doi(dois, scope = identifiers)
          scope
            .where("#{NORMALIZED_SQL} IN (?)", dois)
            .pluck(:identifier_object_id, Arel.sql(NORMALIZED_SQL))
            .each_with_object(Hash.new { |h, k| h[k] = [] }) { |(id, doi), h|
              h[doi] << id
            }
        end

        def prepare(rows, sources)
          # source_id => Set of DOIs
          @dois = Hash.new { |h, k| h[k] = Set.new }
          return if rows.none?(&:doi) || sources.empty?

          self.class.identifiers
            .where(identifier_object_id: sources.map(&:id))
            .pluck(:identifier_object_id, Arel.sql(NORMALIZED_SQL))
            .each { |id, doi| @dois[id] << doi }
        end

        def compare(row, source)
          {
            doi_match: (row.doi && @dois.key?(source.id)) ?
              @dois[source.id].include?(row.doi) : nil
          }
        end

        def score(c)
          c[:doi_match] ? 1.0 : 0.0
        end

      end
    end
  end
end
