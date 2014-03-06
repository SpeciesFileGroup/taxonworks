class DropBiocurationClass < ActiveRecord::Migration
  def change
    drop_table :biocuration_classes
  end
end
