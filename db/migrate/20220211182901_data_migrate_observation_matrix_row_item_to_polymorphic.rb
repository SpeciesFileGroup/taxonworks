class DataMigrateObservationMatrixRowItemToPolymorphic < ActiveRecord::Migration[6.1]

  # !! We mock the two destroyed classes here so that STI can find them on init of the object
  class ObservationMatrixRowItem::Single::Otu < ObservationMatrixRowItem::Single
  end

  class ObservationMatrixRowItem::Single::CollectionObject <  ObservationMatrixRowItem::Single
  end

  def change
    ::ObservationMatrixRowItem.find_each do |o|
      if !o.collection_object_id.nil?
        o.update_columns(
          observation_object_id: o.collection_object_id,
          observation_object_type: 'CollectionObject')
      elsif !o.otu_id.nil?
        o.update_columns(
          observation_object_id: o.otu_id,
          observation_object_type: 'Otu')
      else
        puts "!! Bad observation_matrix_row_item: #{o.id}, not linked to object"
      end
    end
  end
end
