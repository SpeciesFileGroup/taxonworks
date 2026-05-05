class BackfillDwcOccurrenceOtuId < ActiveRecord::Migration[8.1]
  def up
    # AssertedDistribution: OTU is the asserted_distribution_object when type = 'Otu'
    execute <<~SQL
      UPDATE dwc_occurrences
      SET otu_id = asserted_distributions.asserted_distribution_object_id
      FROM asserted_distributions
      WHERE dwc_occurrences.dwc_occurrence_object_type = 'AssertedDistribution'
        AND dwc_occurrences.dwc_occurrence_object_id = asserted_distributions.id
        AND asserted_distributions.asserted_distribution_object_type = 'Otu'
        AND dwc_occurrences.otu_id IS NULL
    SQL

    # CollectionObject: OTU from the position-1 (current) TaxonDetermination
    execute <<~SQL
      UPDATE dwc_occurrences
      SET otu_id = taxon_determinations.otu_id
      FROM taxon_determinations
      WHERE dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'
        AND dwc_occurrences.dwc_occurrence_object_id = taxon_determinations.taxon_determination_object_id
        AND taxon_determinations.taxon_determination_object_type = 'CollectionObject'
        AND taxon_determinations.position = 1
        AND dwc_occurrences.otu_id IS NULL
    SQL

    # FieldOccurrence: same pattern as CollectionObject
    execute <<~SQL
      UPDATE dwc_occurrences
      SET otu_id = taxon_determinations.otu_id
      FROM taxon_determinations
      WHERE dwc_occurrences.dwc_occurrence_object_type = 'FieldOccurrence'
        AND dwc_occurrences.dwc_occurrence_object_id = taxon_determinations.taxon_determination_object_id
        AND taxon_determinations.taxon_determination_object_type = 'FieldOccurrence'
        AND taxon_determinations.position = 1
        AND dwc_occurrences.otu_id IS NULL
    SQL
  end

  def down
    # otu_id is maintained by application code going forward; clearing it here
    # would break existing functionality, so this migration is irreversible.
    raise ActiveRecord::IrreversibleMigration
  end
end
