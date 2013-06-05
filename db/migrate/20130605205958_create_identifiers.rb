class CreateIdentifiers < ActiveRecord::Migration
  def change
    create_table :identifiers do |t|
      t.integer :identifiable_id
      t.string :indentifiable_type
      t.string :identifier
      t.string :type

      t.timestamps
    end
  end
end
