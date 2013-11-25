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

  # Move the BibTeX bibliography into TaxonWorks records
  # @note Not yet implemented!
  # @param input_bibliography [BibTeX::Bibliography] the set of BibTeX records to be converted to TW records.
  # @return [Array<Source::Bibtex>] a set of TW Source::Bibtex records (records may or may not exist in the database.)
  def bibtex_biblio_2_tw(input_bibliography)
    # input BibTeX-ruby bibliography (hash)
    # output TaxonWorks source records (hash?, array?)
  end

  # Save a BibTeX::Entry object as a Source::Bibtex record
  # @note Not yet implemented
  # @param bibtex_entry [BibTeX::Entry] bibtex object to be converted and saved to the database
  # @param tw_entry [Source::Bibtex] will be overwritten with a new Source::Bibtex.
  # @return [Boolean] True if successfully saved to the database; False if not saved.
  def save_bibtex_entry_as_tw(bibtex_entry, tw_entry)
    # Save a TaxonWorks record
  end

  # Create a Source::Bibtex object from a BibTeX::Entry object
  # @note Note yet implemented
  # @param bibtex_entry [BibTeX::Entry] bibtex object to be converted
  # @return [Source::Bibtex] a TW bibtex source object (which may or may not be valid.)
  def create_tw_source_from_bibtex(bibtex_entry)
    #return Source::Bibtex
  end

  # SourceClass function should write to db
end