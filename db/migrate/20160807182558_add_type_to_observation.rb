class AddTypeToObservation < ActiveRecord::Migration
  def change
    add_column :observations, :type, :string, null: false
  end
end
