# these are the bibtex fields that TW will support
BIBTEX_FIELDS = [
    :address,
    :annote,
    :author,
    :booktitle,
    :chapter,
    :crossref,
    :edition,
    :editor,
    :howpublished,
    :institution,
    :journal,
    :key,
    :month,
    :note,
    :number,
    :organization,
    :pages,
    :publisher,
    :school,
    :series,
    :title,
    :volume,
    :year,
    :URL,
    :ISBN,
    :ISSN,
    :LCCN,
    :abstract,
    :keywords,
    :price,
    :copyright,
    :language,
    :contents,
    :stated_year,
    :bibtex_type
]

# The following list is from http://rubydoc.info/gems/bibtex-ruby/2.3.4/BibTeX/Entry
VALID_BIBTEX_TYPES = %w{
      article
      book
      booklet
      conference
      inbook
      incollection
      inproceedings
      manual
      mastersthesis
      misc
      phdthesis
      proceedings
      techreport
      unpublished}
