class CreateSpecimens < ActiveRecord::Migration[4.2]
  def change
    create_table :specimens do |t|

      t.timestamps
    end
  end
end
