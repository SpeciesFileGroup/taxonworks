class CreateSpecimens < ActiveRecord::Migration
  def change
    create_table :specimens do |t|

      t.timestamps
    end
  end
end
