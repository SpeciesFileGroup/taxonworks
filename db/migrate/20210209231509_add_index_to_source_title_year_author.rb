class AddIndexToSourceTitleYearAuthor < ActiveRecord::Migration[6.0]
  def change
    add_index :sources, :year
    add_index :sources, :title
    add_index :sources, :author
  end
end
