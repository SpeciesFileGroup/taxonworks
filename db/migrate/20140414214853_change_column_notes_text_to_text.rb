class ChangeColumnNotesTextToText < ActiveRecord::Migration[4.2]
  def change
    change_column :notes, :text, :text
  end
end
