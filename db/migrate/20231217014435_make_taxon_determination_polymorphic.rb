class MakeTaxonDeterminationPolymorphic < ActiveRecord::Migration[6.1]
  def change
    add_column :taxon_determinations, :taxon_determination_object_id, :bigint # added secondarily post data migration
    add_column :taxon_determinations, :taxon_determination_object_type, :string # added secondairly post data migration

    add_index :taxon_determinations, [:taxon_determination_object_type, :taxon_determination_object_id], name: :td_poly
  end
end
