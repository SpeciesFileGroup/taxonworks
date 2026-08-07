class DataMigrateObservationMatrixRowItemType < ActiveRecord::Migration[6.1]
  def change
    # Truncate subclasses to single class now that we have observation_object
    ObservationMatrixRowItem.all.find_each do |r|
      if r.type =~ /Single/
        r.update_columns(type: 'ObservationMatrixRowItem::Single')
      end
    end
  end
end
