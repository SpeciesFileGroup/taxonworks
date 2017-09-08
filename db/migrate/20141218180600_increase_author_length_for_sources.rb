class IncreaseAuthorLengthForSources < ActiveRecord::Migration[4.2]
  def change
    remove_column :sources, :author
    add_column :sources, :author, :text
  end
end
