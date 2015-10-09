class RemoveUnusedPeopleIdColumsnFromLoans < ActiveRecord::Migration
  def change
   remove_column :loans, :recipient_person_id
   remove_column :loans, :supervisor_person_id 
  end
end
