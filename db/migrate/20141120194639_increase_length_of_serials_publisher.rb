class IncreaseLengthOfSerialsPublisher < ActiveRecord::Migration[4.2]
  def change
    remove_column :serials, :publisher
    add_column :serials, :publisher, :text
  end
end
