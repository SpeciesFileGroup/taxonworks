class AddOriginatingAddressToLoan < ActiveRecord::Migration[4.2]
  def change
    add_column :loans, :lender_address, :text, null: false, default: "Lender's address not provided."
  end
end
