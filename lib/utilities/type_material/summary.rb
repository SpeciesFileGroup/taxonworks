# Pure, agnostic aggregations for the Type material dashboard. Each method
# operates on plain Ruby data (arrays/hashes/Dates) gathered by the caller —
# no ActiveRecord or Rails dependencies.
#
# @author Claude (>50% of code)
#
module Utilities::TypeMaterial::Summary

  # Label used in place of a blank/absent grouping value.
  UNSPECIFIED = 'Unspecified'.freeze

  # Coverage of a set of names by TypeMaterial.
  #
  # @param date_counts [Array<Array(Date, Integer)>] one pair per name:
  #   its nomenclature date and the number of TypeMaterial records it has
  # @return [Hash] { with:, without:, total: }
  def self.coverage_totals(date_counts)
    total = date_counts.size
    with = date_counts.count { |_date, count| count.to_i > 0 }
    { with:, without: total - with, total: }
  end

  # Contiguous decade windows (min..max present decade) counting names
  # with/without TypeMaterial. Names without a year are reported separately.
  #
  # @param date_counts [Array<Array(Date, Integer)>]
  # @return [Hash] { windows: [{ decade:, with:, without: }], without_year: }
  def self.decade_windows(date_counts)
    dated = date_counts.reject { |date, _count| date.nil? }
    without_year = date_counts.size - dated.size

    return { windows: [], without_year: } if dated.empty?

    years = dated.map { |date, _count| date.year }
    min_decade = (years.min / 10) * 10
    max_decade = (years.max / 10) * 10

    buckets = {}
    (min_decade..max_decade).step(10) { |decade| buckets[decade] = { with: 0, without: 0 } }

    dated.each do |date, count|
      decade = (date.year / 10) * 10
      buckets[decade][count.to_i > 0 ? :with : :without] += 1
    end

    windows = buckets.map { |decade, counts| { decade:, with: counts[:with], without: counts[:without] } }

    { windows:, without_year: }
  end

  # Descending count of values (e.g. type_type strings).
  #
  # @param values [Array<String>]
  # @return [Hash{String => Integer}]
  def self.counts(values)
    counts = Hash.new(0)
    values.each { |value| counts[value] += 1 }
    counts.sort_by { |_value, count| -count }.to_h
  end

  # Build a stacked structure: x-axis categories, one series per stack key,
  # values summed. Categories are ordered by total descending, UNSPECIFIED last.
  #
  # @param entries [Array<Array(String, String, Integer)>] [category, stack, value]
  # @param stacks [Array<String>] the (ordered) set of stack series keys
  # @return [Hash] { categories:, type_types:, series: [{ type_type:, data: }] }
  def self.stacked(entries, stacks:)
    grouped = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    entries.each do |category, stack, value|
      grouped[category][stack] += value
    end

    categories = grouped.keys.sort_by do |category|
      [category == UNSPECIFIED ? 1 : 0, -grouped[category].values.sum]
    end

    series = stacks.map do |stack|
      {
        type_type: stack,
        data: categories.map { |category| grouped[category][stack] }
      }
    end

    { categories:, type_types: stacks, series: }
  end

end
