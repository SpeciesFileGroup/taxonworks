class Source < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.references :serial, index: true

      # normally rails uses type as the sti column, we'll use source_type because bibtex uses type as entry type.
      t.string :source_type

      # below are bibtex standard fields
      #address is SF pub.placepublished,
      t.string :address
      t.string :annote
      # author is verbatim author and should be aliased to verbatim_author
      t.string :author
      t.string :booktitle, :chapter, :crossref, :edition
      t.string :editor, :howpublished, :institution
      # bibtex journal will map to  reference serial
      t.string :journal
      t.string :key, :month, :note
      # bibtex number is SF issue
      t.string :number
      t.string :organization, :pages, :publisher, :school, :series, :title, :type, :volume, :year
      t.string :URL, :ISBN, :ISSN, :LCCN, :abstract, :keywords, :price, :copyright, :language, :contents

      # above are bibtex standard fields, below are extras we need.
      t.string :stated_year

      #verbatim is the whole verbatim source string
      t.string :verbatim
      t.string :cached
      # MX short citation == cached_author_year
      t.string :cached_author_year

      t.timestamps
    end
  end
end
