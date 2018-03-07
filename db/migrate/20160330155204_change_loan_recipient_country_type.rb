class ChangeLoanRecipientCountryType < ActiveRecord::Migration[4.2]
  def change
    remove_column :loans, :recipient_country, :integer
    add_column :loans, :recipient_country, :string
  end
end
