class IncreaseCopyrightSize < ActiveRecord::Migration[4.2]
  def change
    change_column :sources, :copyright, :text
  end
end
