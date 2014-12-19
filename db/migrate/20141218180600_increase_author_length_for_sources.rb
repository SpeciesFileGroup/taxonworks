class IncreaseAuthorLengthForSources < ActiveRecord::Migration
  def change
    remove_column :sources, :author
    add_column :sources, :author, :text
  end
end
