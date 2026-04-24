class AddOriginOtuIdToAnatomicalPart < ActiveRecord::Migration[7.2]
  def change
    add_reference :anatomical_parts, :cached_otu, foreign_key: { to_table: :otus }
  end
end
