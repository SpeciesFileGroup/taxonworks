class UnsetLoanLendersAddressDefault < ActiveRecord::Migration
  def change
    change_column :loans, :lender_address, :text, default: nil, null: false

  end
end
