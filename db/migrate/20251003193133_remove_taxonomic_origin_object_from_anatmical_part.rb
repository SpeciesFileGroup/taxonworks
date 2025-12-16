class RemoveTaxonomicOriginObjectFromAnatmicalPart < ActiveRecord::Migration[7.2]
  def change
    remove_column :anatomical_parts, :taxonomic_origin_object_id, :integer
    remove_column :anatomical_parts, :taxonomic_origin_object_type, :string
  end
end
