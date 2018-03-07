class AddTypeToObservation < ActiveRecord::Migration[4.2]
  def change
    add_column :observations, :type, :string, null: false
  end
end
