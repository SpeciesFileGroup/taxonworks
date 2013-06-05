class CreateSpecimenDeterminations < ActiveRecord::Migration
  def change
    create_table :specimen_determinations do |t|
      t.references :otu_id, index: true
      t.references :specimen_id, index: true

      t.timestamps
    end
  end
end
