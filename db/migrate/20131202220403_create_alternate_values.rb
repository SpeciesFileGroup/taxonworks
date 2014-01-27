class CreateAlternateValues < ActiveRecord::Migration
  def change
    create_table :alternate_values do |t|
      t.text :value
      t.string :type
      t.references :language, index: true
      t.string :alternate_type
      t.integer :alternate_id
      t.string :alternate_attribute

      t.timestamps
    end
  end
end
