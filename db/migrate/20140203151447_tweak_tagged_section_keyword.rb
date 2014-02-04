class TweakTaggedSectionKeyword < ActiveRecord::Migration
  def change
    remove_column :tagged_section_keywords, :keyword_references
    add_column    :tagged_section_keywords, :keyword_id, :integer
  end
end
