class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :type
      t.string :last_name
      t.string :first_name
      t.string :initials

      t.timestamps
    end
  end
end
