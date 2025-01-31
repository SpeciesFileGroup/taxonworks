class ChangeOtuNameToText < ActiveRecord::Migration[7.2]
  def change
    change_column(:otus, :name, :text)
  end
end
