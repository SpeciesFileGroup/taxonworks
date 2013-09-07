class CreateTaxonNames < ActiveRecord::Migration
  def change
    create_table :taxon_names do |t|
      t.string :name
      t.integer :parent_id
      t.string :cached_name
      t.string :cached_author_year
      t.string :higher_classification
      t.integer :lft
      t.integer :rgt
      t.integer :original_description_source_id

      t.timestamps
    end
  end
end
