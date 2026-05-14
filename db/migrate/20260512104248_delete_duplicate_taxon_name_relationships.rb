class DeleteDuplicateTaxonNameRelationships < ActiveRecord::Migration[8.1]
  # TaxonNameRelationship has two kinds of associated data: citations and notes.
  #
  # Duplicate detection mirrors the model's uniqueness validations:
  #   combinations    (type ~ OriginalCombination|::Combination):
  #                   PARTITION BY type, object_taxon_name_id, project_id
  #   non-combinations:
  #                   PARTITION BY type, subject_taxon_name_id, object_taxon_name_id, project_id
  #
  # We keep the lowest-id record in each group and delete the rest.
  #
  # Safety check: raises if any higher-id duplicate has notes (not auto-moveable).
  # Citations on higher-id duplicates are re-pointed to the surviving lower-id record
  # (skipping any source already cited there) before the duplicate is deleted.
  def up
    transaction do
      duplicates_with_notes = execute(<<~SQL).to_a
        SELECT tnr.id
        FROM taxon_name_relationships tnr
        WHERE tnr.id IN (
          SELECT id FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, object_taxon_name_id, project_id
                     ORDER BY id
                   ) AS rn
            FROM taxon_name_relationships
            WHERE type ~ 'OriginalCombination|::Combination'
            UNION ALL
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, subject_taxon_name_id, object_taxon_name_id, project_id
                     ORDER BY id
                   ) AS rn
            FROM taxon_name_relationships
            WHERE type !~ 'OriginalCombination|::Combination'
          ) ranked
          WHERE rn > 1
        )
        AND EXISTS (
          SELECT 1 FROM notes WHERE note_object_type = 'TaxonNameRelationship' AND note_object_id = tnr.id
        )
      SQL

      if duplicates_with_notes.any?
        ids = duplicates_with_notes.map { |r| r['id'] }.join(', ')
        raise "Cannot delete duplicate TaxonNameRelationships with notes. " \
              "Clean up notes on IDs: #{ids}"
      end

      # Citations on conflicting duplicates (same source as survivor) are deleted
      # rather than moved. If those citations carry CitationTopics the topics would
      # be silently lost, so we raise here just as we do for notes.
      duplicates_with_citation_topics = execute(<<~SQL).to_a
        SELECT tnr.id
        FROM taxon_name_relationships tnr
        WHERE tnr.id IN (
          SELECT id FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, object_taxon_name_id, project_id
                     ORDER BY id
                   ) AS rn
            FROM taxon_name_relationships
            WHERE type ~ 'OriginalCombination|::Combination'
            UNION ALL
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, subject_taxon_name_id, object_taxon_name_id, project_id
                     ORDER BY id
                   ) AS rn
            FROM taxon_name_relationships
            WHERE type !~ 'OriginalCombination|::Combination'
          ) ranked
          WHERE rn > 1
        )
        AND EXISTS (
          SELECT 1
          FROM citations c
          JOIN citation_topics ct ON ct.citation_id = c.id
          WHERE c.citation_object_type = 'TaxonNameRelationship'
            AND c.citation_object_id = tnr.id
        )
      SQL

      if duplicates_with_citation_topics.any?
        ids = duplicates_with_citation_topics.map { |r| r['id'] }.join(', ')
        raise "Cannot delete duplicate TaxonNameRelationships whose citations have CitationTopics. " \
              "Reroute CitationTopics on IDs: #{ids}"
      end

      duplicate_rows = execute(<<~SQL).to_a
        SELECT id, survivor_id FROM (
          SELECT id,
                 FIRST_VALUE(id) OVER (
                   PARTITION BY type, object_taxon_name_id, project_id
                   ORDER BY id
                 ) AS survivor_id,
                 ROW_NUMBER() OVER (
                   PARTITION BY type, object_taxon_name_id, project_id
                   ORDER BY id
                 ) AS rn
          FROM taxon_name_relationships
          WHERE type ~ 'OriginalCombination|::Combination'
          UNION ALL
          SELECT id,
                 FIRST_VALUE(id) OVER (
                   PARTITION BY type, subject_taxon_name_id, object_taxon_name_id, project_id
                   ORDER BY id
                 ) AS survivor_id,
                 ROW_NUMBER() OVER (
                   PARTITION BY type, subject_taxon_name_id, object_taxon_name_id, project_id
                   ORDER BY id
                 ) AS rn
          FROM taxon_name_relationships
          WHERE type !~ 'OriginalCombination|::Combination'
        ) ranked
        WHERE rn > 1
      SQL

      citations_moved   = 0
      citations_deleted = 0

      duplicate_rows.each do |row|
        duplicate_id = row['id'].to_i
        survivor_id  = row['survivor_id'].to_i

        # Move citations whose (source_id, pages) pair does not already exist on the survivor.
        # Checking source_id alone would incorrectly skip citations with the same source but
        # different pages — those are distinct per the model's uniqueness validation.
        citations_moved += execute(<<~SQL).cmd_tuples
          UPDATE citations
          SET citation_object_id = #{survivor_id}
          WHERE citation_object_type = 'TaxonNameRelationship'
            AND citation_object_id = #{duplicate_id}
            AND (source_id, COALESCE(pages, '')) NOT IN (
              SELECT source_id, COALESCE(pages, '')
              FROM citations
              WHERE citation_object_type = 'TaxonNameRelationship'
                AND citation_object_id = #{survivor_id}
            )
        SQL

        citations_deleted += execute(<<~SQL).cmd_tuples
          DELETE FROM citations
          WHERE citation_object_type = 'TaxonNameRelationship'
            AND citation_object_id = #{duplicate_id}
        SQL
      end

      say "Moved #{citations_moved} citations to surviving taxon_name_relationships"
      say "Deleted #{citations_deleted} conflicting citations from duplicate taxon_name_relationships"

      tnr_result = execute(<<~SQL)
        DELETE FROM taxon_name_relationships
        WHERE id IN (
          SELECT id FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, object_taxon_name_id, project_id
                     ORDER BY id
                   ) AS rn
            FROM taxon_name_relationships
            WHERE type ~ 'OriginalCombination|::Combination'
            UNION ALL
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, subject_taxon_name_id, object_taxon_name_id, project_id
                     ORDER BY id
                   ) AS rn
            FROM taxon_name_relationships
            WHERE type !~ 'OriginalCombination|::Combination'
          ) ranked
          WHERE rn > 1
        )
      SQL
      say "Deleted #{tnr_result.cmd_tuples} duplicate taxon_name_relationships"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
