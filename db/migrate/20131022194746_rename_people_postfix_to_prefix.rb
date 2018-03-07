class RenamePeoplePostfixToPrefix < ActiveRecord::Migration[4.2]
  def change
    rename_column :people, :postfix, :prefix
  end
end
