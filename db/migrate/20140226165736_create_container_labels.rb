class CreateContainerLabels < ActiveRecord::Migration
  def change
    create_table :container_labels do |t|
      t.text :label
      t.date :date_printed
      t.string :print_style
      t.integer :position
      t.integer :created_by_id
      t.integer :modified_by_id
      t.integer :project_id

      t.timestamps
    end
  end
end
