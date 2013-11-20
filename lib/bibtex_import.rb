class BibtexImport


  def bibtex_read (input_file)
    # Open a BibTeX file & read in a bibliography
    # @note Current version opens a fixed file ("spec/files/Taenionema.bib") for testing purposes.
    #   needs to eventually get the input_file name from the user.
    # @!attribute input_file [String]
    input_file = Rails.root + 'spec/files/Taenionema.bib' # will eventually get this from the user
    # TODO get input filename from parameter input_file
    BibTeX.open(input_file)
    # this returns BibTex-ruby bibliography hash
  end

  def bibtex2tw
    # @note Not yet implemented!
    # Move the BibTeX records into TaxonWorks records
    # input BibTeX-ruby bibliography (hash)
    # output TaxonWorks source records (hash?, array?)
  end

  # Save a TaxonWorks record
  # SourceClass function should write to db
end