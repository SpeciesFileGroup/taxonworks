class RemoveVerbatimOriginConstraintFromExtract < ActiveRecord::Migration[4.2]
  def change
    change_column :extracts, :verbatim_anatomical_origin, :string, null: true
  end
end
