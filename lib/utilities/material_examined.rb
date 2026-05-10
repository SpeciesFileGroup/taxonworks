# Renders DarwinCore occurrence data as material examined sections
# for taxonomic publications. Rails-agnostic; suitable for gem extraction.
#
# Usage:
#   renderer = Utilities::MaterialExamined.new(occurrences, order: [...], augmentations: {...})
#   renderer.render  # => Markdown string
#
# occurrences: Array of hashes with DwC string keys (as from DwcOccurrence#dwc_json)
# augmentations: Hash keyed by occurrenceID value:
#   { 'urn:uuid:...' => { label: 'USNM 1234', identifiers: [...] }, ... }
#
module Utilities
  class MaterialExamined

    # DwC field name for each loop variable
    LOOP_VARIABLES = {
      type_status: 'typeStatus',
      country:     'country',
      state:       'stateProvince',
      county:      'county',
      identifier:  'catalogNumber',
      sex:         'sex',
      stage:       'lifeStage',
      repository:  'institutionCode'
    }.freeze

    # Default nesting order for loops
    DEFAULT_ORDER = [
      :type_status,
      :country, :state, :county,
      :identifier,
      :sex,
      :stage,
      :repository
    ].freeze

    # Sort position for primary type designations
    TYPE_STATUS_SORT = {
      'holotype'     => 0,
      'lectotype'    => 1,
      'neotype'      => 2,
    }.freeze

    attr_reader :occurrences, :order, :augmentations

    # @param occurrences [Array<Hash>] DwC occurrence records (string keys)
    # @param order [Array<Symbol>] nesting order using keys from LOOP_VARIABLES
    # @param augmentations [Hash] occurrence-level additions keyed by occurrenceID
    def initialize(occurrences, order: DEFAULT_ORDER, augmentations: {})
      @occurrences   = occurrences
      @order         = order
      @augmentations = augmentations
    end

    # @return [String] Markdown-formatted material examined text
    def render
      return '' if occurrences.empty?

      sorted = sort_by_type_status(occurrences)

      # When type_status is the first loop key, render each status block as its
      # own paragraph so that holotype/paratypes are visually separated.
      if order.first == :type_status
        blocks = group_ordered_by_type_status(sorted)
        blocks.map { |ts_val, records|
          body = render_group(records, order[1..])
          ts_val.empty? ? body : "**#{format_type_status(ts_val)}** #{body}"
        }.join("\n\n")
      else
        render_group(sorted, order)
      end
    end

    private

    # Sort records so primary types come first, then plural types, then others.
    def sort_by_type_status(records)
      records.sort_by { |r| type_status_sort_key(r['typeStatus'].to_s.downcase.strip) }
    end

    def type_status_sort_key(ts)
      return TYPE_STATUS_SORT[ts] if TYPE_STATUS_SORT.key?(ts)
      return 3 if ts.end_with?('s')  # paratypes, syntypes, paralectotypes, …
      return 5 if ts.empty?
      4
    end

    # Returns an ordered array of [type_status_value, records] pairs preserving
    # the sort order from sort_by_type_status.
    def group_ordered_by_type_status(sorted_records)
      groups = []
      current_key = nil

      sorted_records.each do |r|
        key = r['typeStatus'].to_s.strip
        if key != current_key
          current_key = key
          groups << [key, [r]]
        else
          groups.last[1] << r
        end
      end

      groups
    end

    # Recursively renders a set of records using the remaining loop keys.
    def render_group(records, keys)
      return render_leaf(records) if keys.empty? || records.empty?

      key   = keys.first
      rest  = keys[1..]
      field = LOOP_VARIABLES[key]

      # Preserve insertion order (Ruby 1.9+) so geography comes out in the
      # order records were sorted.
      grouped = {}
      records.each do |r|
        val = r[field].to_s.strip
        (grouped[val] ||= []) << r
      end

      parts = grouped.map { |val, group_records|
        inner = render_group(group_records, rest)
        val.empty? ? inner : "**#{val}**: #{inner}"
      }

      parts.compact.join('; ')
    end

    # Renders the leaf node: specimen count plus optional label from augmentations.
    def render_leaf(records)
      count = records.sum { |r| [r['individualCount'].to_i, 1].max }

      labels = records.filter_map { |r|
        aug = augmentations[r['occurrenceID']]
        aug&.dig(:label)
      }

      count_str  = count.to_s
      label_part = labels.empty? ? '' : " (#{labels.join('; ')})"
      "#{count_str}#{label_part}"
    end

    def format_type_status(ts)
      ts.upcase
    end
  end
end
