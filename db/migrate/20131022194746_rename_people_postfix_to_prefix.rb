class RenamePeoplePostfixToPrefix < ActiveRecord::Migration
  def change
    rename_column :people, :postfix, :prefix
  end
end
