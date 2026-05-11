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

    # Lambdas that extract a grouping value from a DwC occurrence hash.
    LOOP_VARIABLES = {
      type_status:          ->(r) { r['typeStatus'].to_s.strip },
      country:              ->(r) { r['country'].to_s.strip },
      state:                ->(r) { r['stateProvince'].to_s.strip },
      county:               ->(r) { r['county'].to_s.strip },
      identifier_namespace: ->(r) { catalog_namespace(r['catalogNumber']) },
      identifier:           ->(r) { catalog_identifier(r['catalogNumber']) },
      sex:                  ->(r) { r['sex'].to_s.strip },
      stage:                ->(r) { r['lifeStage'].to_s.strip },
      repository:           ->(r) { r['institutionCode'].to_s.strip }
    }.freeze

    # Default nesting order for loops.
    # :repository groups by institutionCode first so the institution appears once
    # as a bold header. :identifier then shows just the numeric part of catalogNumber
    # within that group (no namespace prefix needed).
    # :identifier_namespace is intentionally absent from the default; add it to a
    # custom order when catalog-number prefixes differ across specimens in the same
    # repository group.
    DEFAULT_ORDER = [
      :type_status,
      :country, :state, :county,
      :repository,
      :identifier,
      :sex,
      :stage
    ].freeze

    # Sort position for primary type designations
    TYPE_STATUS_SORT = {
      'holotype'  => 0,
      'lectotype' => 1,
      'neotype'   => 2,
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
      # own paragraph so holotype/paratypes are visually separated.
      if order.first == :type_status
        blocks = group_ordered_by_type_status(sorted)
        blocks.map { |ts_val, records|
          total = total_specimens(records)
          body  = render_group(records, order[1..])
          ts_val.empty? ? body : "**#{ts_val.upcase}** (#{total}) #{body}"
        }.join("\n\n")
      else
        render_group(sorted, order)
      end
    end

    # --- class-level catalog number helpers (used by LOOP_VARIABLES lambdas) ---

    # Returns the namespace portion of a catalogNumber string.
    # e.g. "USNM 1234" => "USNM", "MCZ:Ent:12345" => "MCZ:Ent", "1234" => ""
    def self.catalog_namespace(catalog_number)
      s = catalog_number.to_s.strip
      return '' if s.empty?

      # Preferred: text + separator + trailing digits
      if (m = s.match(/\A(.+?)[\s:_-]+\d+\z/))
        m[1].strip
      # Fallback: non-digit prefix + digits
      elsif (m = s.match(/\A(\D+)\d+\z/))
        m[1].strip
      else
        ''
      end
    end

    # Returns the identifier (numeric) portion of a catalogNumber string.
    # e.g. "USNM 1234" => "1234", "MCZ:Ent:12345" => "12345", "ABC" => "ABC"
    def self.catalog_identifier(catalog_number)
      s = catalog_number.to_s.strip
      (m = s.match(/(\d+)\z/)) ? m[1] : s
    end

    private

    # Delegate to class methods so lambdas in LOOP_VARIABLES can call them.
    def catalog_namespace(val) = self.class.catalog_namespace(val)
    def catalog_identifier(val) = self.class.catalog_identifier(val)

    def sort_by_type_status(records)
      records.sort_by { |r| type_status_sort_key(r['typeStatus'].to_s.downcase.strip) }
    end

    def type_status_sort_key(ts)
      return TYPE_STATUS_SORT[ts] if TYPE_STATUS_SORT.key?(ts)
      return 3 if ts.end_with?('s')   # paratypes, syntypes, paralectotypes, …
      return 5 if ts.empty?
      4
    end

    # Returns an ordered array of [type_status_value, records] pairs preserving
    # the sort order established by sort_by_type_status.
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

      key  = keys.first
      rest = keys[1..]

      extractor = LOOP_VARIABLES[key]

      # Preserve insertion order so geography is rendered in sorted order.
      grouped = {}
      records.each do |r|
        val = extractor.call(r)
        (grouped[val] ||= []) << r
      end

      if key == :identifier
        render_identifier_group(grouped, rest)
      elsif key == :identifier_namespace && rest.first == :identifier
        # Paired namespace+identifier: render as "NAMESPACE NUMBER-RANGE [content]"
        # rather than "**NAMESPACE**: NUMBER-RANGE [content]" to keep them together.
        parts = grouped.map { |ns_val, group_records|
          id_extractor = LOOP_VARIABLES[:identifier]
          id_grouped = {}
          group_records.each do |r|
            id_val = id_extractor.call(r)
            (id_grouped[id_val] ||= []) << r
          end
          render_identifier_group(id_grouped, rest[1..], namespace: ns_val)
        }
        parts.compact.join('; ')
      else
        parts = grouped.map { |val, group_records|
          inner = render_group(group_records, rest)
          val.empty? ? inner : "**#{val}**: #{inner}"
        }
        parts.compact.join('; ')
      end
    end

    # Renders the :identifier level with consecutive-range detection.
    # Numeric identifiers that are consecutive AND share the same inner content
    # are collapsed into a range label, e.g. "1234-6".
    # @param namespace [String] optional prefix prepended to each range label
    def render_identifier_group(grouped, rest, namespace: '')
      numeric  = {}
      other    = {}

      grouped.each do |val, recs|
        val.match?(/\A\d+\z/) ? numeric[val.to_i] = recs : other[val] = recs
      end

      parts = []

      ns_prefix = namespace.empty? ? '' : "#{namespace} "

      # Non-numeric identifiers — no bold, namespace prefixed
      other.each do |val, recs|
        inner = render_group(recs, rest)
        label = val.empty? ? ns_prefix.strip : "#{ns_prefix}#{val}"
        parts << (label.empty? ? inner : "#{label} #{inner}")
      end

      # Numeric identifiers — group by inner content, then detect consecutive runs
      unless numeric.empty?
        # Pre-render inner content keyed by numeric id
        rendered = numeric.transform_values { |recs| render_group(recs, rest) }

        # Group ids that share the same inner content
        by_content = {}
        numeric.keys.sort.each do |n|
          (by_content[rendered[n]] ||= []) << n
        end

        by_content.each do |inner, ids|
          consecutive_runs(ids).each do |run|
            num_label = run.length == 1 ? run.first.to_s : range_label(run.first, run.last)
            label     = "#{ns_prefix}#{num_label}"
            parts << "#{label} #{inner}"
          end
        end
      end

      parts.compact.join('; ')
    end

    # Splits a sorted array of integers into runs of consecutive numbers.
    # [1, 2, 3, 5, 6] => [[1, 2, 3], [5, 6]]
    def consecutive_runs(sorted_ints)
      return [] if sorted_ints.empty?

      runs = [[sorted_ints.first]]
      sorted_ints[1..].each do |n|
        if n == runs.last.last + 1
          runs.last << n
        else
          runs << [n]
        end
      end
      runs
    end

    # Formats a numeric range as an abbreviated string.
    # Only abbreviates when start and end share at least 2 leading digits,
    # e.g. range_label(1234, 1236) => "1234-6"
    #      range_label(1000, 1234) => "1000-1234" (shared prefix only "1", no abbreviation)
    def range_label(start_num, end_num)
      return start_num.to_s if start_num == end_num

      s = start_num.to_s
      e = end_num.to_s

      # Find length of shared prefix
      i = 0
      i += 1 while i < s.length && i < e.length && s[i] == e[i]

      return "#{s}-#{e}" if i < 2

      suffix      = e[i..]
      abbreviated = "#{s}-#{suffix}"
      full        = "#{s}-#{e}"

      abbreviated.length < full.length ? abbreviated : full
    end

    def total_specimens(records)
      records.sum { |r| [r['individualCount'].to_i, 1].max }
    end

    # Renders the leaf node: specimen count plus optional labels from augmentations.
    def render_leaf(records)
      count = total_specimens(records)

      labels = records.filter_map { |r|
        aug = augmentations[r['occurrenceID']]
        aug&.dig(:label)
      }

      label_part = labels.empty? ? '' : " #{labels.join('; ')}"
      "(#{count}#{label_part})"
    end
  end
end
