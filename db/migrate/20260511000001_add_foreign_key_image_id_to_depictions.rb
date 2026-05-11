class AddForeignKeyImageIdToDepictions < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :depictions, :images
  end
end
