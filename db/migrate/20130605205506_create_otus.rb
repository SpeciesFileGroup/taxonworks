class CreateOtus < ActiveRecord::Migration
  def change
    create_table :otus do |t|
      t.string :name

      t.timestamps
    end
  end
end
