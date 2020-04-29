class AddPersonIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :person, foreign_key: true
  end
end
