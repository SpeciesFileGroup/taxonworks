class CreateSpecimenIndividuals < ActiveRecord::Migration
  def change
    create_table :specimen_individuals do |t|

      t.timestamps
    end
  end
end
