class TweakTaggedSectionKeyword < ActiveRecord::Migration[4.2]
  def change
    remove_column :tagged_section_keywords, :keyword_references
    add_column    :tagged_section_keywords, :keyword_id, :integer
  end
end
