# Methods for compacting (merging rows) in DarwinCore tables.
#
# @author Claude (>50% of code)
#
module Utilities::DarwinCore::Compact

  MALE_STRINGS = /\Amale/i
  FEMALE_STRINGS = /\Afemale/i
  ADULT_STRINGS = /\Aadult/i
  EXUVIA_STRINGS = /\Aexuvia/i
  NYMPH_STRINGS = /\Anymph/i

  COMPACT_DELIMITER = '|'

  APPENDED_COLUMNS = %w[lifeStage sex otherCatalogNumbers].freeze
  SUMMED_COLUMNS = %w[individualCount].freeze
  DERIVED_COLUMNS = %w[adultMale adultFemale immatureNymph exuvia].freeze

  # Columns excluded from the differing-values validation check.
  # These are housekeeping or per-row identity fields that are
  # expected to differ across rows sharing a catalogNumber.
  SKIP_VALIDATION_COLUMNS = %w[
    id
    occurrenceID
    dwc_occurrence_object_id
    dwc_occurrence_object_type
  ].freeze

  # Merge rows with identical catalogNumber values.
  # Rows without a catalogNumber are excluded from compaction
  # but tracked in table.skipped_rows.
  #
  # @param table [Utilities::DarwinCore::Table]
  # @param preview [Boolean] if true, log errors without modifying data
  # @return [void]
  def self.by_catalog_number(table, preview: false)
    with_catalog_number, without_catalog_number = table.rows.partition { |row|
      row['catalogNumber'].to_s.strip.present?
    }

    table.skipped_rows = without_catalog_number

    grouped = with_catalog_number.group_by { |row| row['catalogNumber'] }

    merged_rows = []

    grouped.each do |catalog_number, rows_in_group|
      if rows_in_group.size == 1
        row = rows_in_group.first
        unless preview
          add_derived_columns(row)
          merged_rows << row
        end
        next
      end

      validate_group(table, catalog_number, rows_in_group)

      unless preview
        merged = merge_group(table, catalog_number, rows_in_group)
        merged_rows << merged
      end
    end

    unless preview
      ensure_derived_headers(table)
      table.instance_variable_set(:@rows, merged_rows)
    end
  end

  # Validate a group of rows sharing a catalogNumber.
  # Logs errors for columns with differing values.
  # Warns if sex/lifeStage are non-adult.
  #
  # @param table [Utilities::DarwinCore::Table]
  # @param catalog_number [String]
  # @param rows [Array<Hash>]
  # @return [void]
  def self.validate_group(table, catalog_number, rows)
    operated_columns = APPENDED_COLUMNS + SUMMED_COLUMNS + SKIP_VALIDATION_COLUMNS

    (table.headers - operated_columns).each do |column|
      values = rows.map { |r| r[column] }.uniq
      if values.size > 1
        table.errors << {
          type: :error,
          catalog_number:,
          column:,
          message: "Differing values in '#{column}' for catalogNumber '#{catalog_number}'",
          values:
        }
      end
    end

    rows.each do |row|
      sex_value = row['sex'].to_s.strip
      life_stage_value = row['lifeStage'].to_s.strip

      if sex_value.present? && !sex_value.match?(MALE_STRINGS) && !sex_value.match?(FEMALE_STRINGS)
        if !life_stage_value.match?(ADULT_STRINGS)
          table.errors << {
            type: :warning,
            catalog_number:,
            column: 'sex',
            message: "Non-adult/non-standard sex '#{sex_value}' with lifeStage '#{life_stage_value}' for catalogNumber '#{catalog_number}'",
            values: [sex_value, life_stage_value]
          }
        end
      end

      if life_stage_value.present? && !life_stage_value.match?(ADULT_STRINGS)
        unless life_stage_value.match?(NYMPH_STRINGS) || life_stage_value.match?(EXUVIA_STRINGS)
          table.errors << {
            type: :warning,
            catalog_number:,
            column: 'lifeStage',
            message: "Non-adult lifeStage '#{life_stage_value}' for catalogNumber '#{catalog_number}'",
            values: [life_stage_value]
          }
        end
      end
    end
  end

  # Merge a group of rows into a single row.
  #
  # @param table [Utilities::DarwinCore::Table]
  # @param catalog_number [String]
  # @param rows [Array<Hash>]
  # @return [Hash] the merged row
  def self.merge_group(table, catalog_number, rows)
    merged = rows.first.dup

    # Sum individualCount
    SUMMED_COLUMNS.each do |col|
      merged[col] = rows.sum { |r| r[col].to_i }.to_s
    end

    # Append unique values with delimiter
    APPENDED_COLUMNS.each do |col|
      unique_values = rows.map { |r| r[col].to_s.strip }.reject(&:empty?).uniq
      merged[col] = unique_values.join(COMPACT_DELIMITER)
    end

    add_derived_columns_from_group(merged, rows)

    merged
  end

  # Add derived columns from a group of pre-merge rows.
  #
  # @param merged [Hash] the target merged row
  # @param rows [Array<Hash>] original rows
  # @return [void]
  def self.add_derived_columns_from_group(merged, rows)
    adult_male_count = 0
    adult_female_count = 0
    immature_nymph_count = 0
    exuvia_count = 0

    rows.each do |row|
      count = row['individualCount'].to_i
      sex_value = row['sex'].to_s.strip
      life_stage_value = row['lifeStage'].to_s.strip

      adult_male_count += count if sex_value.match?(MALE_STRINGS)
      adult_female_count += count if sex_value.match?(FEMALE_STRINGS)
      immature_nymph_count += count if life_stage_value.match?(NYMPH_STRINGS)
      exuvia_count += count if life_stage_value.match?(EXUVIA_STRINGS)
    end

    merged['adultMale'] = adult_male_count.to_s
    merged['adultFemale'] = adult_female_count.to_s
    merged['immatureNymph'] = immature_nymph_count.to_s
    merged['exuvia'] = exuvia_count.to_s
  end

  # Add derived columns to a single (non-grouped) row.
  #
  # @param row [Hash]
  # @return [void]
  def self.add_derived_columns(row)
    count = row['individualCount'].to_i
    sex_value = row['sex'].to_s.strip
    life_stage_value = row['lifeStage'].to_s.strip

    row['adultMale'] = (sex_value.match?(MALE_STRINGS) ? count : 0).to_s
    row['adultFemale'] = (sex_value.match?(FEMALE_STRINGS) ? count : 0).to_s
    row['immatureNymph'] = (life_stage_value.match?(NYMPH_STRINGS) ? count : 0).to_s
    row['exuvia'] = (life_stage_value.match?(EXUVIA_STRINGS) ? count : 0).to_s
  end

  # Ensure derived column headers are present in the table.
  #
  # @param table [Utilities::DarwinCore::Table]
  # @return [void]
  def self.ensure_derived_headers(table)
    DERIVED_COLUMNS.each do |col|
      table.headers << col unless table.headers.include?(col)
    end
  end

  private_class_method :validate_group, :merge_group, :add_derived_columns_from_group, :add_derived_columns, :ensure_derived_headers
end
