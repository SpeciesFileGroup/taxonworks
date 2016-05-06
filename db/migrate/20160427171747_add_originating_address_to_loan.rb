class AddOriginatingAddressToLoan < ActiveRecord::Migration
  def change
    add_column :loans, :lender_address, :text, null: false, default: "Lender's address not provided."
  end
end
