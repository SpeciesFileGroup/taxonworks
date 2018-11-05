class AddRecipientHonorariumToLoans < ActiveRecord::Migration[4.2]
  def change
    add_column :loans, :recipient_honorarium, :string
  end
end
