class IncreaseCopyrightSize < ActiveRecord::Migration
  def change
    change_column :sources, :copyright, :text
  end
end
