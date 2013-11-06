class CreateBiocurationClasses < ActiveRecord::Migration
  def change
    create_table :biocuration_classes do |t|
      t.string :name

      t.timestamps
    end
  end
end
