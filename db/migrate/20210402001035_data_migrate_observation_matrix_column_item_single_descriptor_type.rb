class DataMigrateObservationMatrixColumnItemSingleDescriptorType < ActiveRecord::Migration[6.0]
  def change
    target = ObservationMatrixColumnItem::Single::Descriptor

    ObservationMatrixColumnItem.connection.execute(
      <<~SQL
        UPDATE #{target.table_name}
        SET type = '#{target.to_s}'
        WHERE type = 'ObservationMatrixColumnItem::SingleDescriptor';
      SQL
    )
  end
end
