class RenameLoanColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :loans, :recipient_honorarium, :recipient_honorific
  end
end
