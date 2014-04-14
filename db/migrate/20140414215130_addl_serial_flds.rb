class AddlSerialFlds < ActiveRecord::Migration
  def change
    rename_column :serials, :full_name, :name
    add_column :serials, :publisher, :string
    add_column :serials, :place_published, :string
    add_column :serials, :primary_language_id, :integer

    add_column :serials, :first_year_of_issue, :integer, :limit=>2 # sets year to smallint (<32767)
    add_column :serials, :last_year_of_issue, :integer, :limit=>2 # sets year to smallint (<32767)

  end
end
