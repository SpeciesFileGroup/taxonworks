# Summary helpers that aggregate DarwinCore Occurrence data alone (no
# TaxonWorks or Rails coupling). Each method operates on an Array of plain
# row Hashes keyed by DwC term (e.g. 'sex', 'country', 'decimalLatitude').
#
# These are intentionally generic so they can be reused by any task that
# already has DwcOccurrence rows in hand (see the Type material dashboard).
#
# @author Claude (>50% of code)
#
module Utilities::DarwinCore::TypeMaterialSummary

  # Label used in place of a blank/absent value.
  UNSPECIFIED = 'Unspecified'.freeze

  # Count rows by their `sex` value. Blank/absent values are grouped under
  # UNSPECIFIED. Counts rows (records), not individuals.
  #
  # @param rows [Array<Hash>]
  # @return [Hash{String => Integer}] sex value => count, descending by count
  def self.sex_counts(rows)
    count_by(rows, 'sex')
  end

  # Count rows by their `country` value. Blank/absent values are grouped
  # under UNSPECIFIED.
  #
  # @param rows [Array<Hash>]
  # @return [Hash{String => Integer}] country => count, descending by count
  def self.country_counts(rows)
    count_by(rows, 'country')
  end

  # Partition rows into georeferenced / not, based on the presence of both
  # `decimalLatitude` and `decimalLongitude`.
  #
  # @param rows [Array<Hash>]
  # @return [Hash] { georeferenced:, not_georeferenced:, total: }
  def self.georeference_partition(rows)
    georeferenced = rows.count { |row| georeferenced?(row) }
    {
      georeferenced:,
      not_georeferenced: rows.size - georeferenced,
      total: rows.size
    }
  end

  # @param row [Hash]
  # @return [Boolean] true when both coordinate terms are present
  def self.georeferenced?(row)
    present?(row['decimalLatitude']) && present?(row['decimalLongitude'])
  end

  # Generic descending count of rows by a column, blanks => UNSPECIFIED.
  #
  # @param rows [Array<Hash>]
  # @param column [String]
  # @return [Hash{String => Integer}]
  def self.count_by(rows, column)
    counts = Hash.new(0)
    rows.each do |row|
      value = row[column]
      key = present?(value) ? value.to_s : UNSPECIFIED
      counts[key] += 1
    end
    counts.sort_by { |_key, count| -count }.to_h
  end

  # @param value [Object, nil]
  # @return [Boolean]
  def self.present?(value)
    !value.nil? && value.to_s.strip.length > 0
  end

end
