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
  :url,
  :isbn,
  :issn,
  :abstract,
  :verbatim_keywords, #was keywords
  :copyright,
  :language,
  :stated_year,
  :year_suffix,
  :bibtex_type
].freeze

# :lccn,
# :price,
# :contents,

# The following lists are from http://rubydoc.info/gems/bibtex-ruby/2.3.4/BibTeX/Entry
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
  unpublished}.freeze

VALID_BIBTEX_MONTHS = %w{
  jan
  feb
  mar
  apr
  may
  jun
  jul
  aug
  sep
  oct
  nov
  dec}.freeze
