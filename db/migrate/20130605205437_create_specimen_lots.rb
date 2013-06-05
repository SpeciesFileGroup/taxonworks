class CreateSpecimenLots < ActiveRecord::Migration
  def change
    create_table :specimen_lots do |t|

      t.timestamps
    end
  end
end
