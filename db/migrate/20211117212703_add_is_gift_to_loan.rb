class AddIsGiftToLoan < ActiveRecord::Migration[6.1]
  def change
    add_column :loans, :is_gift, :boolean
  end
end
