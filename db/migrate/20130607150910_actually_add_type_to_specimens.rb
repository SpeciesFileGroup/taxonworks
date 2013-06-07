class ActuallyAddTypeToSpecimens < ActiveRecord::Migration
  def change
    add_column :specimens, :type, :string, null: false
  end
end
