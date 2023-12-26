class AddLongTermLoanToLoans < ActiveRecord::Migration[6.1]
  def change
    add_column :loans, :is_long_term_loan, :boolean
  end
end
