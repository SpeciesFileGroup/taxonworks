class UnsetLoanLendersAddressDefault < ActiveRecord::Migration[4.2]
  def change
    change_column :loans, :lender_address, :text, default: nil, null: false

  end
end
