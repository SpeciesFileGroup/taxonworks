class ChangeColumnNotesTextToText < ActiveRecord::Migration
  def change
    change_column :notes, :text, :text
  end
end
