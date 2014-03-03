class CreateLoanItems < ActiveRecord::Migration
  def change
    create_table :loan_items do |t|
      t.references :loan, index: true
      t.references :collection_object, index: true
      t.date :date_returned
      t.string :collection_object_status
      t.integer :position
      t.integer :created_by_id
      t.integer :modified_by_id
      t.integer :project_id

      t.timestamps
    end
  end
end
