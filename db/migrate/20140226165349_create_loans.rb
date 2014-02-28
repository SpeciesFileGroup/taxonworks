class CreateLoans < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.date :date_requested
      t.string :request_method
      t.date :date_sent
      t.date :date_received
      t.date :date_return_expected
      t.integer :recipient_person_id
      t.string :recipient_address
      t.string :recipient_email
      t.string :recipient_phone
      t.integer :recipient_country
      t.string :supervisor_person_id
      t.string :supvervisor_email
      t.string :supervisor_phone
      t.date :date_closed
      t.integer :created_by_id
      t.integer :modified_by_id
      t.integer :project_id

      t.timestamps
    end
  end
end
