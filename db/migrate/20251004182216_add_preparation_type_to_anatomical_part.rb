class AddPreparationTypeToAnatomicalPart < ActiveRecord::Migration[7.2]
  def change
    add_reference :anatomical_parts, :preparation_type, foreign_key: { to_table: :preparation_types }
  end
end
