class RemoveVerbatimOriginConstraintFromExtract < ActiveRecord::Migration
  def change
    change_column :extracts, :verbatim_anatomical_origin, :string, null: true
  end
end
