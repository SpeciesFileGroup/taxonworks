# Created by CLAUDE code.
#
# Fix duplicate year_suffix values in Source::Bibtex records.
# See https://github.com/SpeciesFileGroup/taxonworks/issues/4684
#
# For each set of duplicates (same author, year, year_suffix):
# - Order by created_at (oldest first)
# - Append '_unplaced1', '_unplaced2', etc. in order
#
# Also updates the cached column since it includes year_suffix in the rendered
# citation.
class FixDuplicateYearSuffixes < ActiveRecord::Migration[7.2]
  def up
    # Find all duplicate (author, year, year_suffix) combinations
    duplicates = Source
      .where(type: 'Source::Bibtex')
      .where.not(year_suffix: [nil, ''])
      .where.not(year: nil)
      .where.not(author: [nil, ''])
      .group(:author, :year, :year_suffix)
      .having('COUNT(*) > 1')
      .pluck(:author, :year, :year_suffix)

    total_updated = 0

    duplicates.each do |author, year, year_suffix|
      # Get all sources in this duplicate group, ordered by created_at (oldest first)
      sources = Source::Bibtex
        .where(author: author, year: year, year_suffix: year_suffix)
        .order(:created_at, :id)
        .to_a

      # Append _unplaced suffix to all duplicates
      sources.each_with_index do |source, index|
        new_suffix = "#{source.year_suffix}_unplaced#{index + 1}"

        # Bypass validations and callbacks for the year_suffix update
        source.update_columns(year_suffix: new_suffix)

        # Refresh the cached value since it includes year_suffix
        source.send(:set_cached)

        total_updated += 1
      end
    end

    puts "Updated #{total_updated} Source records with duplicate year_suffix values"
  end

  def down
    # This migration cannot be automatically reversed because we don't store
    # the original values. Manual intervention would be needed.
    raise ActiveRecord::IrreversibleMigration
  end
end
