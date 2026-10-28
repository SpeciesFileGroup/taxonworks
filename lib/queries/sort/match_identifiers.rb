# The `match_identifiers` sort key: orders records in the order their
# identifiers (or internal ids) were given in the `match_identifiers` param,
# see the matching facet in Queries::Concerns::Identifiers.
#
# Reads the params as the facet does, so the sort matches what the facet
# found: the same types, caseless rule and, for containable models, records
# matched by the identifier of a container they're in.
module Queries
  module Sort
    class MatchIdentifiers
      include Queries::Helpers

      KEY = 'match_identifiers'.freeze

      TYPES = %w[internal identifier dwc_occurrence_id].freeze

      DWC_OCCURRENCE_ID_TYPE = 'Identifier::Global::Uuid::TaxonworksDwcOccurrence'.freeze

      # Larger internal ids can't be ids, and fail as a bigint.
      MAX_ID = 2**63 - 1

      ALIAS = 'sort_match_identifiers'.freeze

      # @return [Array<String>] the identifiers in `value`, in order, without
      #   duplicates; only digit strings in the bigint range when `type` is
      #   'internal'
      def self.identifiers(value, delimiter: nil, type: nil)
        return [] if value.blank?

        ids = value.to_s.strip.split(normalize_delimiter(delimiter)).map(&:strip).reject(&:blank?).uniq
        ids = ids.select { |i| i =~ /\A\d+\z/ && i.to_i <= MAX_ID } if type.to_s.downcase == 'internal'
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
        # Caseless unless false, read as the facet reads it.
        @caseless = boolean_param(params, :match_identifiers_caseless) != false
        @identifiers = self.class.identifiers(
          params[:match_identifiers],
          delimiter: params[:match_identifiers_delimiter],
          type: @type
        )
      end

      # @return [Boolean] whether there is anything to sort by
      def active?
        TYPES.include?(@type) && @identifiers.any?
      end

      # @return [ActiveRecord::Relation] query ordered by the position of each
      #   record's identifier in the given list, records without one last;
      #   unchanged if not active?
      def apply(query, dir = :asc)
        return query if !active?

        table = @klass.table_name

        expr =
          if @type == 'internal'
            "array_position(ARRAY[#{@identifiers.join(',')}]::bigint[], #{table}.id::bigint)"
          else
            query = query.joins(lateral_sql(table))
            "#{ALIAS}.s"
          end

        node = Arel.sql(expr)
        query.order((dir == :desc ? node.desc : node.asc).nulls_last)
      end

      private

      def connection = ApplicationRecord.connection

      def quote(value) = connection.quote(value)

      # The best (lowest) position among the record's matching identifiers,
      # as an aggregate so it's always one row per record.
      def lateral_sql(table)
        positions = [own_positions_sql(table)]
        positions << container_positions_sql(table) if @klass.try(:is_containable?)

        <<~SQL.squish
          LEFT JOIN LATERAL (
            SELECT MIN(m.s) AS s FROM (#{positions.join(' UNION ALL ')}) m
          ) AS #{ALIAS} ON true
        SQL
      end

      def own_positions_sql(table)
        values = @caseless ? @identifiers.map(&:downcase) : @identifiers
        cached = @caseless ? 'LOWER(sid.cached)' : 'sid.cached'

        <<~SQL.squish
          SELECT array_position(ARRAY[#{values.map { |v| quote(v) }.join(',')}]::text[], #{cached}::text) AS s
          FROM identifiers sid
          WHERE sid.identifier_object_id = #{table}.id
            AND sid.identifier_object_type = #{quote(@klass.base_class.name)}
            AND #{cached} IN (#{values.map { |v| quote(v) }.join(',')})
            #{type_condition('sid')}
        SQL
      end

      # Identifiers of containers the record is in, at any depth. Matched as
      # given (not caseless), as in the facet's container match.
      def container_positions_sql(table)
        values = @identifiers.map { |v| quote(v) }.join(',')

        <<~SQL.squish
          SELECT array_position(ARRAY[#{values}]::text[], cid.cached::text) AS s
          FROM container_items sci
          JOIN container_item_hierarchies scih ON scih.descendant_id = sci.id
          JOIN container_items sci2 ON sci2.id = scih.ancestor_id AND sci2.contained_object_type = 'Container'
          JOIN identifiers cid ON cid.identifier_object_id = sci2.contained_object_id AND cid.identifier_object_type = 'Container'
          WHERE sci.contained_object_id = #{table}.id
            AND sci.contained_object_type = #{quote(@klass.base_class.name)}
            AND cid.cached IN (#{values})
            #{type_condition('cid')}
        SQL
      end

      def type_condition(table_alias)
        return '' if @type != 'dwc_occurrence_id'

        "AND #{table_alias}.type = #{quote(DWC_OCCURRENCE_ID_TYPE)}"
      end
    end
  end
end
