class AddTaxonomyOriginToAnatomicalPart < ActiveRecord::Migration[7.2]
  def change
    add_column :anatomical_parts, :taxonomic_origin_object_id, :integer, null: false
    add_column :anatomical_parts, :taxonomic_origin_object_type, :string, null: false

    add_index :anatomical_parts,
      [:taxonomic_origin_object_id, :taxonomic_origin_object_type],
      name: 'anatomical_part_polymorphic_taxonomic_origin_index'
  end
end
