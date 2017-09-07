class DropBiocurationClass < ActiveRecord::Migration[4.2]
  def change
    drop_table :biocuration_classes
  end
end
