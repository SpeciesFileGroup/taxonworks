class FixIdsInSpecimenDeterminations < ActiveRecord::Migration
  def change
    rename_column(:specimen_determinations, :otu_id_id, :otu_id)
    rename_column(:specimen_determinations, :specimen_id_id, :specimen_id)
  end
end
