class IncreaseLengthOfSerialsName < ActiveRecord::Migration
  def change
    remove_column :serials, :name
    add_column :serials, :name, :text

  end
end
