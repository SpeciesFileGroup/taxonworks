class CreateCollectingEvents < ActiveRecord::Migration
  def change
    create_table :collecting_events do |t|
      t.text :verbatim_label
      t.text :print_label
      t.integer :print_label_number_to_print
      t.text :document_label
      t.string :verbatim_locality
      t.string :verbatim_longitude
      t.string :verbatim_latitude
      t.string :verbatim_geolocation_uncertainty
      t.string :verbatim_trip_identifier
      t.string :verbatim_collectors
      t.string :verbatim_method
      t.references :geographic_area, index: true
      t.decimal :minimum_elevation
      t.decimal :maximum_elevation
      t.string :elevation_unit
      t.string :elevation_precision
      t.time :time_start
      t.time :time_end
      t.string :start_date_day
      t.string :start_date_month
      t.string :start_date_year
      t.string :end_date_day
      t.string :end_date_month
      t.string :end_date_year
      t.string :micro_habitat
      t.string :macro_habitat
      t.text :field_notes
      t.string :verbatim_label_md5
      t.references :confidence, index: true

      t.timestamps
    end
  end
end
