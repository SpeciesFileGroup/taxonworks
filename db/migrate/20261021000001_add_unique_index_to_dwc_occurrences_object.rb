# A CollectionObject/FieldOccurrence/etc. has_one dwc_occurrence; enforce it.
# Besides catching duplicates, a unique index lets Postgres drop the sort join
# on dwc_occurrences from pagination COUNT queries (it can then prove the
# LEFT JOIN matches at most one row).
#
# Duplicates are not removed here: each dwc_occurrence carries the
# occurrenceID UUID that may already have been published, so which one to keep
# is a curation decision. The migration stops and lists them instead.
class AddUniqueIndexToDwcOccurrencesObject < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = :index_dwc_occurrences_on_object_unique
  OLD_INDEX_NAME = :dwc_occurrences_object_index

  def up
    duplicates = select_rows(<<~SQL)
      SELECT dwc_occurrence_object_type, dwc_occurrence_object_id, array_agg(id ORDER BY id)
      FROM dwc_occurrences
      GROUP BY dwc_occurrence_object_type, dwc_occurrence_object_id
      HAVING COUNT(*) > 1
      ORDER BY 1, 2
      LIMIT 50
    SQL

    if duplicates.any?
      raise <<~MSG
        dwc_occurrences has more than one row for some objects (first 50 shown,
        as object type, object id, dwc_occurrence ids). Resolve them, then rerun:
        #{duplicates.map { |d| d.join(' ') }.join("\n")}
      MSG
    end

    add_index :dwc_occurrences,
      [:dwc_occurrence_object_id, :dwc_occurrence_object_type],
      unique: true,
      name: INDEX_NAME,
      algorithm: :concurrently,
      if_not_exists: true

    # Same columns, now redundant.
    remove_index :dwc_occurrences, name: OLD_INDEX_NAME, algorithm: :concurrently, if_exists: true
  end

  def down
    add_index :dwc_occurrences,
      [:dwc_occurrence_object_id, :dwc_occurrence_object_type],
      name: OLD_INDEX_NAME,
      algorithm: :concurrently,
      if_not_exists: true

    remove_index :dwc_occurrences, name: INDEX_NAME, algorithm: :concurrently, if_exists: true
  end
end
