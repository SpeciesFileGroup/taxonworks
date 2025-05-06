class CreateLeadItems < ActiveRecord::Migration[7.2]
  def change
    create_table :lead_items do |t|
      t.integer :lead_id, null: false, index: true
      t.integer :otu_id, null: false, index: true
      t.references :project, null: false, foreign_key: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.integer :position

      t.timestamps
    end
  end
end
