# BibtexImport - a library to handle tasks related to importing a BibTeX bibliography.
# It depends on both the bibtex-ruby gem and Source::Bibtex
class BibtexImport

  # Open a BibTeX file & read in a bibliography
  # @param input_file [String] the name of the file containing the BibTeX bibliography.
  # @note Current version opens a fixed file ("spec/files/Taenionema.bib") for testing purposes.
  #   eventually input_file name will be passed in.
  # @return [BibTeX::Bibliography] has the same return values as BibTeX.open()
  def bibtex_read (input_file)

#TODO get input filename from parameter input_file
    input_file = Rails.root + 'spec/files/Taenionema.bib' # will eventually get this from the user
    BibTeX.open(input_file)
# this returns BibTex-ruby bibliography hash
  end

  # Move the BibTeX records into TaxonWorks records
  # @note Not yet implemented!
  def bibtex2tw
    # input BibTeX-ruby bibliography (hash)
    # output TaxonWorks source records (hash?, array?)
  end

  # Save a TaxonWorks record
  # SourceClass function should write to db
end