class DataMigrateObservationMatrixColumnItemSingleDescriptorType < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE observation_matrix_column_items
        SET type = 'ObservationMatrixColumnItem::Single::Descriptor'
        WHERE type = 'ObservationMatrixColumnItem::SingleDescriptor';
      SQL
    )
  end
end
