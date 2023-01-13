class PopulateTaxonNameCachedAuthor < ActiveRecord::Migration[6.1]
  # This is a data migration touching only cached values.
  def change
    TaxonName.where.not(parent_id: nil).each do |t|
      t.update_column(:cached_author, t.get_author)
    end
  end
end
