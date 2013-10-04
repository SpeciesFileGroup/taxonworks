class UpdatePersonToMatchBibTeX < ActiveRecord::Migration
  def change
    remove_column :people, :initials
    add_column :people, :suffix, :string
    add_column :people, :postfix, :string
  end
end
