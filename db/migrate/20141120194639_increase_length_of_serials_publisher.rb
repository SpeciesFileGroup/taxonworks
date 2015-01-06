class IncreaseLengthOfSerialsPublisher < ActiveRecord::Migration
  def change
    remove_column :serials, :publisher
    add_column :serials, :publisher, :text
  end
end
