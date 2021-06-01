class DataMigrateObservationMatrixItemTypes < ActiveRecord::Migration[6.0]
  def change

    # Renames all row/column item types to reflect refactor
    # Note that not all types were used in SFG production prior to migration, but perhaps elsewhere

    row_translate = { 
      "ObservationMatrixRowItem::SingleCollectionObject" => "ObservationMatrixRowItem::Single::CollectionObject",
      "ObservationMatrixRowItem::SingleOtu" =>              "ObservationMatrixRowItem::Single::Otu",
      "ObservationMatrixRowItem::TaxonNameRowItem" =>       "ObservationMatrixRowItem::Dynamic::TaxonName",
      # No dynamic tagged values used yet
    }

    row_translate.each do |k, v| 
      ObservationMatrixRowItem.connection.execute("update observation_matrix_row_items set type = '#{v}' where type = '#{k}';")
    end

    column_translate = {
      "ObservationMatrixColumnItem::SingleDescriptor" => "ObservationMatrixColumnItem::Single::Descriptor",
      # No dynamic tagged descriptors used yet
    }


    row_translate.each do |k, v| 
      ObservationMatrixColumnItem.connection.execute("update observation_matrix_row_items set type = '#{v}' where type = '#{k}';")
    end

  end
end

