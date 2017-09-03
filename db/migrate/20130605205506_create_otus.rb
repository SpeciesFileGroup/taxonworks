class CreateOtus < ActiveRecord::Migration[4.2]
  def change
    create_table :otus do |t|
      t.string :name

      t.timestamps
    end
  end
end
