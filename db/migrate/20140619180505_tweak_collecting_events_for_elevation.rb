class TweakCollectingEventsForElevation < ActiveRecord::Migration
  def change
    remove_column :collecting_events, :elevation_unit
    add_column :collecting_events, :verbatim_elevation, :string
    remove_column :collecting_events, :print_label_number_to_print
    remove_column :collecting_events, :micro_habitat
    remove_column :collecting_events, :macro_habitat
    add_column :collecting_events, :verbatim_habitat, :text

  end
end
