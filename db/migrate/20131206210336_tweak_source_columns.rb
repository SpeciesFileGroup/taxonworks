class TweakSourceColumns < ActiveRecord::Migration
  def change
    add_column :sources, :day, :integer
    
    remove_column :sources, :year
    add_column :sources, :year, :integer

    rename_column :sources, :LCCN, :doi

    remove_column :sources, :ISBN
    add_column :sources, :isbn, :string

    remove_column :sources, :ISSN
    add_column :sources, :issn, :string

    remove_column :sources, :contents
    remove_column :sources, :keywords
    add_column :sources,  :verbatim_contents, :text
    add_column :sources,  :verbatim_keywords, :text

    add_column :sources,  :language_id, :integer 

    # remove_column :sources,  :url 

    add_column :sources, :translator, :string 

    remove_column :sources, :price

  end
end
