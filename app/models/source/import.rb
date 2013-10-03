class Source::Import < Source


  def bibtex_read (input_file)
    # Open a BibTeX file & read in a bibliography
    input_file = Rails.root + "spec/files/Taenionema.bib" # will eventually get this from the user
    BibTeX.open(input_file)
    # this returns BibTex-ruby bibliography hash
  end

  def bibtex2tw
    # Move the BibTeX records into TaxonWorks records
  end

  # Save a TaxonWorks record
  # SourceClass function should write to db
end