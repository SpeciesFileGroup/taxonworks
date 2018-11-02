class AddRecipientHonorificToLoans < ActiveRecord::Migration[4.2]
  def change
    add_column :loans, :recipient_honorific, :string
  end
end
