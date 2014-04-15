class AddRecipientHonorariumToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :recipient_honorarium, :string
  end
end
