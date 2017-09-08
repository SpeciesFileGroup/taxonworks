class IncreaseLengthOfSerialsName < ActiveRecord::Migration[4.2]
  def change
    remove_column :serials, :name
    add_column :serials, :name, :text

  end
end
