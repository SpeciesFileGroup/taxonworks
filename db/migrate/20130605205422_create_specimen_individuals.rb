class CreateSpecimenIndividuals < ActiveRecord::Migration[4.2]
  def change
    create_table :specimen_individuals do |t|

      t.timestamps
    end
  end
end
