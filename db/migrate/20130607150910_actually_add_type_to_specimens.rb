class ActuallyAddTypeToSpecimens < ActiveRecord::Migration[4.2]
  def change
    add_column :specimens, :type, :string, null: false
  end
end
