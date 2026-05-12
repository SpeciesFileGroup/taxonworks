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

    MONTH_ROMAN = %w[i ii iii iv v vi vii viii ix x xi xii].freeze

    SEX_SYMBOLS = {
      'male'          => '♂',
      'female'        => '♀',
      'gynandromorph' => '♂♀'
    }.freeze

    # Lambdas that extract a grouping value from a DwC occurrence hash.
    LOOP_VARIABLES = {
      type_status:          ->(r) { r['typeStatus'].to_s.strip },
      country:              ->(r) { r['country'].to_s.strip },
      state:                ->(r) { r['stateProvince'].to_s.strip },
      county:               ->(r) { r['county'].to_s.strip },
      identifier_namespace: ->(r) { catalog_namespace(r['catalogNumber']) },
      identifier:           ->(r) { catalog_identifier(r['catalogNumber']) },
      sex:                  ->(r) { SEX_SYMBOLS.fetch(normalize_sex(r['sex']), r['sex'].to_s.strip) },
      stage:                ->(r) { r['lifeStage'].to_s.strip },
      repository:           ->(r) { r['institutionCode'].to_s.strip },
      month_range:          ->(r) { m = extract_month(r); m.positive? ? m.to_s : '' },
      # :total is a passthrough — handled before grouping in render_group;
      # the lambda is never called but must exist for controller key validation.
      total:                ->(_r) { '' }
    }.freeze

    DEFAULT_ORDER = [
      :type_status,
      :country, :state, :county,
      :month_range,
      :total,
      :identifier_namespace,
      :identifier,
      :stage,
      :sex,
      :repository
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
    # @param todo [Boolean] when true, blank active-field values render as "[TODO]"
    #   and todo_occurrence_ids is populated for downstream link generation
    def initialize(occurrences, order: DEFAULT_ORDER, augmentations: {}, todo: false)
      @occurrences        = occurrences
      @order              = order
      @augmentations      = augmentations
      @todo               = todo
      @todo_occurrence_ids = []
    end

    attr_reader :todo_occurrence_ids

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

    # --- class-level helpers (used by LOOP_VARIABLES lambdas) ---

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

    # Normalises a raw DwC sex string to a SEX_SYMBOLS key.
    # Handles case, plurals ('females' → 'female'), and gynandromorph variants
    # ('Gynandromorphic', 'gynandomorph', 'gynandromorphs', …).
    def self.normalize_sex(value)
      s = value.to_s.strip.downcase
      # Gynandromorph and its common variants (gynandomorph misspelling, -ic, -s, …)
      return 'gynandromorph' if s.match?(/\Agyn(andro|ando)/)
      # Strip trailing plural 's' for 'males' / 'females'
      s = s.delete_suffix('s') if s.length > 3
      s
    end

    # Returns the month (1–12) from a DwC record, or 0 if absent/invalid.
    # Reads the integer `month` field first; falls back to parsing `eventDate`.
    def self.extract_month(record)
      m = record['month'].to_i
      return m if (1..12).cover?(m)

      date_str = record['eventDate'].to_s
      if (md = date_str.match(/\A\d{4}-(\d{2})/))
        m2 = md[1].to_i
        return m2 if (1..12).cover?(m2)
      end
      0
    end

    private

    # Delegates to class methods so lambdas in LOOP_VARIABLES can call them.
    def catalog_namespace(val) = self.class.catalog_namespace(val)
    def catalog_identifier(val) = self.class.catalog_identifier(val)
    def normalize_sex(val)      = self.class.normalize_sex(val)
    def extract_month(r)        = self.class.extract_month(r)

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

      # :total injects the summed individualCount at this nesting position and
      # continues rendering the remaining keys. render_leaf suppresses its own
      # count whenever :total appears anywhere in the order, avoiding duplication.
      if key == :total
        inner = render_group(records, rest)
        total = total_specimens(records)
        return inner.empty? ? total.to_s : "#{total} #{inner}"
      end

      extractor = LOOP_VARIABLES[key]

      grouped = {}
      records.each do |r|
        val = extractor.call(r)
        if val.empty? && @todo
          val = '[TODO]'
          @todo_occurrence_ids << r['occurrenceID']
        end
        (grouped[val] ||= []) << r
      end

      grouped = grouped.sort.to_h if %i[country state county].include?(key)

      if key == :identifier
        render_identifier_group(grouped, rest)
      elsif key == :month_range
        render_month_group(grouped, rest)
      elsif key == :identifier_namespace && rest.first == :identifier
        # Paired namespace+identifier: "NAMESPACE NUMBER-RANGE [content]"
        parts = grouped.filter_map { |ns_val, group_records|
          id_extractor = LOOP_VARIABLES[:identifier]
          id_grouped = {}
          group_records.each do |r|
            id_val = id_extractor.call(r)
            (id_grouped[id_val] ||= []) << r
          end
          result = render_identifier_group(id_grouped, rest[1..], namespace: ns_val)
          result.empty? ? nil : result
        }
        parts.join('; ')
      elsif key == :repository
        # Show "(CODEN)" even when inner is empty — value still meaningful without sub-detail.
        parts = grouped.filter_map { |val, group_records|
          inner = render_group(group_records, rest)
          next nil if val.empty? && inner.empty?
          val.empty? ? inner : (inner.empty? ? "(#{val})" : "(#{val}): #{inner}")
        }
        parts.reject(&:empty?).join('; ')
      elsif key == :stage
        # Show stage label even when inner is empty.
        parts = grouped.filter_map { |val, group_records|
          inner = render_group(group_records, rest)
          next nil if val.empty? && inner.empty?
          val.empty? ? inner : (inner.empty? ? val : "#{val} #{inner}")
        }
        parts.reject(&:empty?).join('; ')
      elsif key == :sex
        # Show sex symbol even when inner is empty.
        parts = grouped.filter_map { |val, group_records|
          inner = render_group(group_records, rest)
          next nil if val.empty? && inner.empty?
          val.empty? ? inner : (inner.empty? ? "**#{val}**" : "**#{val}**: #{inner}")
        }
        parts.reject(&:empty?).join('; ')
      else
        # Geographic and other grouping levels: skip entirely when inner is empty.
        parts = grouped.filter_map { |val, group_records|
          inner = render_group(group_records, rest)
          next nil if inner.empty?
          val.empty? ? inner : "**#{val}**: #{inner}"
        }
        parts.join('; ')
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
        entry = label.empty? ? inner : (inner.empty? ? label : "#{label} #{inner}")
        parts << entry unless entry.empty?
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

        by_content.each do |_inner, ids|
          consecutive_runs(ids).each do |run|
            run_records    = run.flat_map { |n| numeric[n] }
            combined_inner = render_group(run_records, rest)
            num_label = run.length == 1 ? run.first.to_s : range_label(run.first, run.last)
            label     = "#{ns_prefix}#{num_label}"
            parts << (combined_inner.empty? ? label : "#{label} #{combined_inner}")
          end
        end
      end

      parts.compact.join('; ')
    end

    # Renders the :month_range level with consecutive-month detection.
    # Months are represented as integers ("1"–"12") and rendered as Roman numerals.
    # Consecutive months sharing the same inner content collapse to a range,
    # e.g. months 8 and 9 → "viii–ix". Output preserves chronological order.
    def render_month_group(grouped, rest)
      parts = []

      # Records with no extractable month — rendered last, no month label
      unknown_recs = grouped[''].to_a
      unknown_recs = nil if unknown_recs.empty?

      numeric = {}
      labeled = {}
      grouped.each do |val, recs|
        next if val.empty?
        m = val.to_i
        if m.positive?
          numeric[m] = recs
        else
          labeled[val] = recs  # e.g. '[TODO]'
        end
      end

      # Non-numeric literal labels (e.g. '[TODO]') — rendered before numeric months
      labeled.each do |label, recs|
        content = render_group(recs, rest)
        next if content.empty?
        parts << "#{label}, #{content}"
      end

      unless numeric.empty?
        rendered = numeric.transform_values { |recs| render_group(recs, rest) }
        sorted   = numeric.keys.sort

        # Walk sorted months, collapsing consecutive runs with identical inner content
        i = 0
        while i < sorted.length
          start_m = sorted[i]
          content  = rendered[start_m]
          j = i + 1
          j += 1 while j < sorted.length &&
                        sorted[j] == sorted[j - 1] + 1 &&
                        rendered[sorted[j]] == content
          next if content.empty?
          label = roman_month_range(start_m, sorted[j - 1])
          parts << "#{label}, #{content}"
          i = j
        end
      end

      if unknown_recs
        inner = render_group(unknown_recs, rest)
        parts << inner unless inner.empty?
      end

      parts.join('; ')
    end

    # Formats a month range as Roman numerals with an en-dash separator.
    # roman_month_range(8, 9) => "viii–ix"
    # roman_month_range(7, 7) => "vii"
    def roman_month_range(start_month, end_month)
      start_label = MONTH_ROMAN[start_month - 1]
      return start_label if start_month == end_month
      "#{start_label}–#{MONTH_ROMAN[end_month - 1]}"
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

    # Renders the leaf node.
    # When :total is in the order the count was already shown upstream, so only
    # augmentation labels are emitted here. Without :total the count is shown.
    def render_leaf(records)
      show_labels = order.include?(:identifier) || order.include?(:identifier_namespace)
      labels = show_labels ? records.filter_map { |r|
        aug = augmentations[r['occurrenceID']]
        aug&.dig(:label)
      } : []

      if order.include?(:total)
        labels.empty? ? '' : "(#{labels.join('; ')})"
      else
        count = total_specimens(records)
        labels.empty? ? "(#{count})" : "#{count} (#{labels.join('; ')})"
      end
    end
  end
end
