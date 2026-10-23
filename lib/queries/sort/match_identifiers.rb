# Authored with assistance from Claude (Anthropic)
#
# The `match_identifiers` sort key: orders records in the order their
# identifiers (or internal ids) were given in the `match_identifiers` param,
# see the matching facet in Queries::Concerns::Identifiers.
module Queries
  module Sort
    class MatchIdentifiers

      KEY = 'match_identifiers'.freeze

      # @return [Array<String>] the identifiers in `value`, in order, without
      #   duplicates; only digit strings when `type` is 'internal'
      def self.identifiers(value, delimiter: nil, type: nil)
        return [] if value.blank?

        ids = value.to_s.strip.split(normalize_delimiter(delimiter)).map(&:strip).reject(&:blank?).uniq
        ids = ids.select { |i| i =~ /\A\d+\z/ } if type.to_s.downcase == 'internal'
        ids
      end

      # @return [String] ',' by default; '\n' and '\t' as typed in a form
      #   become newline and tab
      def self.normalize_delimiter(delimiter)
        case delimiter
        when nil then ','
        when '\n', "\n" then "\n"
        when '\t', "\t" then "\t"
        else delimiter
        end
      end

      # @param params [Hash] with indifferent access
      def initialize(klass, params)
        @klass = klass
        @type = params[:match_identifiers_type].to_s.downcase
        # Caseless unless explicitly false.
        @caseless = ![false, 'false'].include?(params[:match_identifiers_caseless])
        @identifiers = self.class.identifiers(
          params[:match_identifiers],
          delimiter: params[:match_identifiers_delimiter],
          type: @type
        )
      end

      # @return [ActiveRecord::Relation] query ordered by the position of each
      #   record's identifier in the given list; unchanged if none were given
      def apply(query)
        return query if @identifiers.empty?

        table = @klass.table_name

        if @type == 'internal'
          ids = @identifiers.map(&:to_i)
          return query.order(Arel.sql("array_position(ARRAY[#{ids.join(',')}]::bigint[], #{table}.id::bigint)"))
        end

        values = @caseless ? @identifiers.map(&:downcase) : @identifiers
        cached = @caseless ? 'LOWER(sid.cached)' : 'sid.cached'
        quoted = values.map { |v| ApplicationRecord.connection.quote(v) }.join(',')

        matched = ::Identifier
          .from('identifiers sid')
          .where("#{cached} IN (?)", values)
          .select("sid.*, array_position(ARRAY[#{quoted}], #{cached}) s")

        query.with(sid: matched)
          .joins("JOIN sid ON sid.identifier_object_id = #{table}.id AND sid.identifier_object_type = #{ApplicationRecord.connection.quote(@klass.base_class.name)}")
          .order(Arel.sql('sid.s'))
      end
    end
  end
end
