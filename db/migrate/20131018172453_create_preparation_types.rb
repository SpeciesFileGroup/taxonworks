class CreatePreparationTypes < ActiveRecord::Migration
  def change
    create_table :preparation_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
