require 'citeproc'
require 'csl/styles'
require 'namecase'

# Bibtex - Subclass of Source that represents most references.
#   Cached values are formatted using the 'zootaxa' style from 'csl/styles'
#
# TaxonWorks(TW) relies on the bibtex-ruby gem to input or output BibTeX bibliographies,
# and has a strict list of required fields. TW itself only requires that :bibtex_type
# be valid and that one of the attributes in TW_REQUIRED_FIELDS be defined.
# This allows a rapid input of incomplete data, but also means that not all TW Source::Bibtex
# objects can be added to a BibTeX bibliography.
#
# The following information is taken from *BibTeXing*, by Oren Patashnik, February 8, 1988
# http://ftp.math.purdue.edu/mirrors/ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf
# (and snippets are cut from this document for the attribute descriptions)
#
# BibTeX fields in a BibTex bibliography are treated in one of three ways:
#
# [REQUIRED]
#   Omitting the field will produce a warning message and, rarely, a badly
#   formatted bibliography entry. If the required information is not meaningful,
#   you are using the wrong entry type. However, if the required information is meaningful
#   but, say, already included is some other field, simply ignore the warning.
# [OPTIONAL]
#   The field's information will be used if present, but can be omitted
#  without causing any formatting problems. You should include the optional
#       field if it will help the reader.
# [IGNORED]
#   The field is ignored. BibTEX ignores any field that is not required or
#optional, so you can include any fields you want in a bib file entry. It's a
#       good idea to put all relevant information about a reference in its bib file
#       entry - even information that may never appear in the bibliography.
#
# Dates in Source Bibtex:
#   It is common for there two be two (or more) dates associated with the origin of a source:
#     1) If you only have reference to a single value, it goes in year (month, day)
#     2) If you have reference to two year values, the actual year of publication goes in year, and the stated year of publication goes in stated_year.
#     3) If you have month or day publication, they go in month or day.
#
#   We do not track stated_month or stated_day if they are present in addition to actual month and actual day.
#
#   BibTeX has month.
#   BibTeX does not have day.
#
# @author Elizabeth Frank <eef@illinois.edu> INHS University of IL
# @author Matt Yoder
#
# @!attribute serial_id [Fixnum]
#   @return [Fixnum] the unique identifier of the serial record in the Serial? table.
#   @return [nil] means the record does not exist in the database.
#   @note not yet implemented!
#   Non-Bibtex attribute that is cross-referenced.
#
# @!attribute address
#   @return [#String] the address
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (optional for types: book, inbook, incollection, inproceedings, manual, mastersthesis,
#   phdthesis, proceedings, techreport)
#   Usually the address of the publisher or other type of institution.
#   For major publishing houses, van Leunen recommends omitting the information
#   entirely. For small publishers, on the other hand, you can help the reader by giving the complete address.
#
# @!attribute annote
#   @return [String] the annotation
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (ignored by standard processors)
#   An annotation. It is not used by the standard bibliography styles, but
#   may be used by others that produce an annotated bibliography.
#   (compare to a note which is any additional information which may be useful to the reader)
#   In most cases these are personal annotations; TW will translate these into notes with a specified project so
#   they will only be visible within the project where the note was made. <== Under debate with Matt.
#
# @!attribute booktitle
#   @return[String] the title of the book
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of the required attributes.)
#   Title of a book, part of which is being cited. See the LaTEX book for how to type titles.
#   For book entries, use the title field instead.
#
# @!attribute chapter
#   @return [String] the chapter or section number.
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   A chapter (or section or whatever) number.
#
# @!attribute crossref
#   @return[String] the key of the cross referenced source
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (ignored by standard processors)
#   The database key(key attribute) of the entry being cross referenced.
#   This attribute is only set (and saved) during the import process, and is only relevant
#   in a specific bibliography.
#
# @!attribute edition
#   @return[String] the edition of the book
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   The edition of a book(for example, "Second"). This should be an ordinal, and should
#   have the first letter capitalized, as shown here;
#   the standard styles convert to lower case when necessary.
#
# @!attribute editor
#   @return [String]
#   @todo
#
# @!attribute howpublished
#   @return[String] a description of how this source was published
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   How something unusual has been published. The first word should be capitalized.
#
# @!attribute institution
#   @return[String] the name of the institution publishing this source
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   The sponsoring institution of a technical report
#
# @!attribute journal
#   @return[String, nil] the name of the journal (serial) associated with this source
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of the required attributes.)
#   A journal name. Many BibTeX processors have standardized abbreviations for many journals
#   which would be listed in your local BibTeX processor guide. Once this attribute has been
#   normalized against TW Serials, this attribute will contain the full journal name as
#   defined by the Serial object. If you want a preferred abbreviation associated with
#   with this journal, add the abbreviation the serial object.
#
# @!attribute key
#   @return [String]
#   BibTeX standard field (may be used in a bibliography for alphabetizing & cross referencing)
#   Used by bibtex-ruby gem method _identifier_ as a default value when no other identifier is present.
#   Used for alphabetizing, cross referencing, and creating a label when the "author" information
#   is missing. This field should not be confused with the key that appears in the \cite (BibTeX/LaTeX)command and at
#   the beginning of the bibliography entry.
#
#   This attribute is only set (and saved) during the import process. It may be generated for output when
#   a bibtex-ruby bibliography is created, but is unlikely to be save to the db.
#   @return[String] the key of this source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute month
#   @return[String] The three-letter lower-case abbreviation for the month in which this source was published.
#   @return [nil] means the attribute is not stored in the database.
#   the actual publication month. a BibTeX standard field (required for types: ) (optional for types:)
#   The month in which the work was published or, for an unpublished work, in which it was written.
#   It should use the standard three-letter abbreviation, as described in Appendix B.1.3 of the LaTeX book.
#   The three-letter lower-case abbreviations are available in _BibTeX::MONTHS_.
#   If month is present there must be a year.
#
# @!attribute note
#   @return[String] the BibTeX note associated with this source
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: unpublished)(optional for types:)
#   Any additional information that can help the reader. The first word should be capitalized.
#
#   This attribute is used on import, but is otherwise ignored.   Updates to this field are
#   NOT transferred to the associated TW note and not added to any export.  TW does NOT allow '|' within a note. (\'s
#   are used to separate multiple TW notes associated with a single object on import)
#
# @!attribute number
#   @return[String] the number in a series, issue or technical report number associated with this source
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   The number of a journal, magazine, technical report, or of a work in a series.
#   An issue of a journal or magazine is usually identified by its volume and number;
#   the organization that issues a technical report usually gives it a number;
#   and sometimes books are given numbers in a named series.
#
#   This attribute is equivalent to the Species File reference issue.
#
# @!attribute organization
#   @return[String] the organization associated with this source
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   The organization that sponsors a conference or that publishes a manual.
#
# @!attribute pages
#   @return [String]
#   BibTeX standard field (required for types: )(optional for types:)
#   One or more page numbers or range of numbers, such as 42--111 or
#   7,41,73--97 or 43+ (the `+' in this last example indicates pages following
#   that don't form a simple range). To make it easier to maintain Scribe-
#   compatible databases, the standard styles convert a single dash (as in
#   7-33) to the double dash used in TeX to denote number ranges (as in 7--33).
#
# @!attribute publisher
#   @return [String]
#   @todo
#
# @!attribute school
#   @return [String]
#   @todo
#
# @!attribute series
#   @return [String]
#   @todo
#
# @!attribute title
#   @return [String]
#   A TW required attribute (TW requires a value in one of the required attributes.)
#
# @!attribute type
#   @return [String]
#   @todo
#
# @!attribute volume
#   @return [String]
#   @todo
#
# @!attribute doi
#   @return [String]
#   Used by bibtex-ruby gem method identifier
#   not implemented yet
#
# @!attribute abstract
#   @return [String]
#   @todo
#
# @!attribute copyright
#   @return [String]
#   @todo
#
# @!attribute language
#   @return [String]
#   @todo
#   BibTeX field for the name of the language used. This value is translated into the TW language_id.
#
# @!attribute stated_year
#   @return [String]
#   @todo
#
# @!attribute verbatim
#   @return [String]
#   Non-Bibtex attribute that is cross-referenced.
#
# @!attribute bibtex_type
#   @return [String]
#    one of VALID_BIBTEX_TYPES (config/initializers/constants/_controlled_vocabularies/bibtex_constants.rb, keys there are symbols)
#
# @!attribute day
#   @return [Integer]
#   the actual publication month, NOT a BibTex standard field
#   If day is present there must be a month and day must be valid for the month.
#
# @!attribute year
#   @return [Integer]
#   the actual publication year. a BibTeX standard field (required for types: ) (optional for types:)
#   A TW required attribute (TW requires a value in one of the required attributes.)
#   Year must be between 1000 and now + 2 years inclusive
#
# @!attribute isbn
#   @return [String]
#   Used by bibtex-ruby gem method identifier
#
# @!attribute issn
#   @return [String]
#   Used by bibtex-ruby gem method identifier
#
# @!attribute verbatim_contents
#   @return [String]
#   @todo
#
# @!attribute verbatim_keywords
#   @return [String]
#   @todo
#
# @!attribute language_id
#   @return [Integer]
#     language, from a controlled vocabulary
#
# @!attribute translator
#   @return [String]
#   bibtex-ruby gem supports translator, it's not clear whether TW will or not.
#   not yet implemented
#
# @!attribute year_suffix
#   @return [String]
#     like 1950a
#
# @!attribute url
#   @return [String]
#   A TW required attribute for certain bibtex_types (TW requires a value in one of the required attributes.)
#
# @!attribute author
#   @return [String, nil] author names preferably rendered in BibTeX format,
#   "Last name, FirstName MiddleName". FirstName and MiddleName can be initials.
#   Additional authors are joined with ` and `. All names before the
#   comma are treated as a single last name.
#
#   The contents of `author` follow the following rules:
#   * `author` (a) and `authors` (People) (b) can both be used to generate the author string
#   * if a & !b then `author` = a verbatim (and therefor may not match the BibTeX format)
#   * if !a & b then `author` = b, collected and rendered in BibTeX format
#   * if a & b then `author` = b, collected and rendered in BibTeX format on each update.  !! Updates to `author` directly will be overwritten !!
#   `author` is automatically populated from `authors` if the latter is provided
#   !! This is different behavious from TaxonName, where `verbatim_author` has priority over taxon_name_author (People) in rendering.
#
#   See also `cached_author_string`
#
class Source::Bibtex < Source

  # Type will change
  DEFAULT_CSL_STYLE = 'zootaxa'

  attr_accessor :authors_to_create

  include Shared::OriginRelationship
  include Source::Bibtex::SoftValidationExtensions::Instance
  extend Source::Bibtex::SoftValidationExtensions::Klass

  is_origin_for 'Source::Bibtex', 'Source::Verbatim'
  originates_from 'Source::Bibtex', 'Source::Verbatim'

  GRAPH_ENTRY_POINTS = [:origin_relationships]

  # Used in soft validation
  BIBTEX_REQUIRED_FIELDS = {
    article: [:author, :title, :journal, :year],
    book: [:author, :editor, :title, :publisher, :year],
    booklet: [:title],
    conference: [:author, :title, :booktitle, :year],
    inbook: [:author, :editor, :title, :chapter, :pages, :publisher, :year],
    incollection: [:author, :title, :booktitle, :publisher, :year],
    inproceedings:  [:author, :title, :booktitle, :year],
    manual: [:title],
    mastersthesis: [:author, :title, :school, :year],
    misc: [],
    phdthesis: [:author, :title, :school, :year],
    proceedings: [:title, :year],
    techreport: [:author,:title,:institution, :year],
    unpublished: [:author, :title, :note]
  }

  # TW required fields (must have one of these fields filled in)
  # either year or stated_year is acceptable
  TW_REQUIRED_FIELDS = [:author, :editor, :booktitle, :title, :url, :journal, :year, :stated_year].freeze

  IGNORE_SIMILAR = [:verbatim, :cached, :cached_author_string, :cached_nomenclature_date].freeze
  IGNORE_IDENTICAL = IGNORE_SIMILAR.dup.freeze

  belongs_to :serial, inverse_of: :sources

  # handle conflict with BibTex language field.
  belongs_to :source_language, class_name: 'Language', foreign_key: :language_id, inverse_of: :sources

  has_many :author_roles, -> { order('roles.position ASC') }, class_name: 'SourceAuthor',
    as: :role_object, validate: true

  has_many :authors, -> { order('roles.position ASC') }, through: :author_roles, source: :person, validate: true

  has_many :editor_roles, -> { order('roles.position ASC') }, class_name: 'SourceEditor',
    as: :role_object, validate: true
  has_many :editors, -> { order('roles.position ASC') }, through: :editor_roles, source: :person, validate: true

  accepts_nested_attributes_for :authors, :editors, :author_roles, :editor_roles, allow_destroy: true

  before_validation :create_authors, if: -> { !authors_to_create.nil? }
  before_validation :check_has_field

  validates_inclusion_of :bibtex_type,
    in: ::VALID_BIBTEX_TYPES,
    message: '"%{value}" is not a valid source type'

  validates_presence_of :year,
    if: -> { !month.blank? || !stated_year.blank? },
    message: 'is required when month or stated_year is provided'

  validates :year, date_year: {
    min_year: 1000, max_year: Time.now.year + 2,
    message: 'must be an integer greater than 999 and no more than 2 years in the future'}

  validates_presence_of :month,
    unless: -> { day.blank? },
    message: 'is required when day is provided'

  validates_inclusion_of :month,
    in: ::VALID_BIBTEX_MONTHS,
    allow_blank: true,
    message: ' month'

  validates :day, date_day: {year_sym: :year, month_sym: :month},
            unless: -> { year.blank? || month.blank? }

  validates :url, format: {
    with: URI::regexp(%w(http https ftp)),
    message: '[%{value}] is not a valid URL'}, allow_blank: true

  validate :italics_are_paired, unless: -> { title.blank? }
  validate :validate_year_suffix, unless: -> { self.no_year_suffix_validation || (self.type != 'Source::Bibtex') }

  # includes nil last, exclude it explicitly with another condition if need be
  scope :order_by_nomenclature_date, -> { order(:cached_nomenclature_date) }

  # @param [BibTeX::Name] bibtex_author
  # @return [Person, Boolean] new person, or false
  def self.bibtex_author_to_person(bibtex_author)
    return false if bibtex_author.class != BibTeX::Name
    p = Person.new(
      first_name: bibtex_author.first,
      prefix: bibtex_author.prefix,
      last_name: bibtex_author.last,
      suffix: bibtex_author.suffix)
    p.namecase_names
    p
  end

  # @return [BibTeX::Entry]
  def self.new_from_bibtex_text(text = nil)
    a = BibTeX::Bibliography.parse(text, filter: :latex).first
    new_from_bibtex(a)
  end

  # Instantiates a Source::Bibtex instance from a BibTeX::Entry
  # Note:
  #    * note conversion is handled in note setter.
  #    * identifiers are handled in associated setter.
  #    * !! Unrecognized attributes are added as import attributes.
  #
  # Usage:
  #    a = BibTeX::Entry.new(bibtex_type: 'book', title: 'Foos of Bar America', author: 'Smith, James', year: 1921)
  #    b = Source::Bibtex.new_from_bibtex(a)
  #
  # @param [BibTex::Entry] bibtex_entry the BibTex::Entry to convert
  # @return [Source::BibTex.new] a new instance
  # @todo annote to project specific note?
  # @todo if it finds one & only one match for serial assigns the serial ID, and if not it just store in journal title
  # serial with alternate_value on name .count = 1 assign .first
  # before validate assign serial if matching & not doesn't have a serial currently assigned.
  # @todo if there is an ISSN it should look up to see it the serial already exists.
  def self.new_from_bibtex(bibtex_entry = nil)
    return false if !bibtex_entry.kind_of?(::BibTeX::Entry)

    s = Source::Bibtex.new(bibtex_type: bibtex_entry.type.to_s)

    import_attributes = []

    bibtex_entry.fields.each do |key, value|
      if key == :keywords
        s.verbatim_keywords = value
        next
      end

      v = value.to_s.strip
      if s.respond_to?(key.to_sym) && key != :type
        s.send("#{key}=", v)
      else
        import_attributes.push({import_predicate: key, value: v, type: 'ImportAttribute'})
      end
    end
    s.data_attributes_attributes = import_attributes
    s
  end

  # @return [Array] journal, nil or name
  def journal
    [read_attribute(:journal), (serial.blank? ? nil : serial.name)].compact.first
  end

  # @return [String]
  def verbatim_journal
    read_attribute(:journal)
  end

  # @return [Boolean]
  #   whether the BibTeX::Entry representation of this source is valid
  def valid_bibtex?
    to_bibtex.valid?
  end

  # @return [String] A string that represents the year with suffix as seen in a BibTeX bibliography.
  #   returns "" if neither :year or :year_suffix are set.
  def year_with_suffix
    [year, year_suffix].compact.join
  end

  # @return [String] A string that represents the authors last_names and year (no suffix)
  def author_year
    return 'not yet calculated' if new_record?
    [cached_author_string, year].compact.join(', ')
  end

  # TODO: Not used
  #
  # Modified from build, the issues with polymorphic has_many and build
  # are more than we want to tackle right now.
  #
  # @return [Array, Boolean] of names, or false
  def create_related_people_and_roles
    return false if !self.valid? ||
      self.new_record? ||
      (self.author.blank? && self.editor.blank?) ||
      self.roles.count > 0

    bibtex = to_bibtex
    ::TaxonWorks::Vendor::BibtexRuby.namecase_bibtex_entry(bibtex)

    begin
      Role.transaction do
        if bibtex.authors
          bibtex.authors.each do |a|
            p = Source::Bibtex.bibtex_author_to_person(a)
            p.save!
            SourceAuthor.create!(role_object: self, person: p)
          end
        end

        if bibtex.editors
          bibtex.editors.each do |a|
            p = Source::Bibtex.bibtex_author_to_person(a)
            p.save!
            SourceEditor.create!(role_object: self, person: p)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      raise
    end
    true
  end

  #region getters & setters

  # @param [String, Integer] value
  # @return [Integer] value of year
  def year=(value)
    if value.class == String
      value =~ /\A(\d\d\d\d)([a-zA-Z]*)\z/
      write_attribute(:year, $1.to_i) if $1
      write_attribute(:year_suffix, $2) if $2
      write_attribute(:year, value) if self.year.blank?
    else
      write_attribute(:year, value)
    end
  end

  # @param [String] value
  # @return [String]
  def month=(value)
    v = Utilities::Dates::SHORT_MONTH_FILTER[value]
    v = v.to_s if !v.nil?
    write_attribute(:month, v)
  end

  # Used only on import from BibTeX records
  # @param [String] value
  # @return [String]
  def note=(value)
    write_attribute(:note, value)
    if !self.note.blank? && self.new_record?
      if value.include?('||')
        a = value.split(/||/)
        a.each do |n|
          self.notes.build({text: n + ' [Created on import from BibTeX.]'})
        end
      else
        self.notes.build({text: value + ' [Created on import from BibTeX.]'})
      end
    end
  end

  # @param [String] value
  # @return [String]
  def isbn=(value)
    write_attribute(:isbn, value)
    unless value.blank?
      if tw_isbn = self.identifiers.where(type: 'Identifier::Global::Isbn').first
        if tw_isbn.identifier != value
          tw_isbn.destroy!
          self.identifiers.build(type: 'Identifier::Global::Isbn', identifier: value)
        end
      else
        self.identifiers.build(type: 'Identifier::Global::Isbn', identifier: value)
      end
    end
  end

  # @return [String]
  def isbn
    identifier_string_of_type('Identifier::Global::Isbn')
  end

  # @param [String] value
  # @return [String]
  def doi=(value)
    write_attribute(:doi, value)
    unless value.blank?
      if tw_doi = self.identifiers.where(type: 'Identifier::Global::Doi').first
        if tw_doi.identifier != value
          tw_doi.destroy!
          self.identifiers.build(type: 'Identifier::Global::Doi', identifier: value)
        end
      else
        self.identifiers.build(type: 'Identifier::Global::Doi', identifier: value)
      end
    end
  end

  # @return [String]
  def doi
    identifier_string_of_type('Identifier::Global::Doi')
  end

  # @todo Are ISSN only Serials now? Maybe - the raw bibtex source may come in with an ISSN in which case
  # we need to set the serial based on ISSN.
  # @param [String] value
  # @return [String]
  def issn=(value)
    write_attribute(:issn, value)
    unless value.blank?
      tw_issn = self.identifiers.where(type: 'Identifier::Global::Issn').first
      unless tw_issn.nil? || tw_issn.identifier != value
        tw_issn.destroy
      end
      self.identifiers.build(type: 'Identifier::Global::Issn', identifier: value)
    end
  end

  # @return [String]
  def issn
    identifier_string_of_type('Identifier::Global::Issn')
  end

  # turn bibtex URL field into a Ruby URI object
  # @return [URI]
  def url_as_uri
    URI(self.url) unless self.url.blank?
  end

  # @param [String] type_value
  # @return [Identifier]
  #   the identifier of this type, relies on Identifier to enforce has_one for Global identifiers
  #   !! behaviour for Identifier::Local types may be unexpected
  def identifier_string_of_type(type_value)
    # Also handle in memory
    identifiers.each do |i|
      return i.identifier if i.type == type_value
    end
    nil
    # identifiers.where(type: type_value).first&.identifier
  end

 #endregion getters & setters

  # @return [Boolean]
  # is there a bibtex author or author roles?
  def has_authors?
    return true if !author.blank?
    return false if new_record?
    # self exists in the db
    authors.count > 0 ? true : false
  end

  # @return [Boolean]
  def has_editors?
    return true if editor
    # editor attribute is empty
    return false if new_record? # WHY!?
    # self exists in the db
    editors.count > 0 ? true : false
  end

  # @return [Boolean]
  #  true contains either an author or editor
  def has_writer?
    (has_authors? || has_editors?) ? true : false
  end

  # @return [Boolean]
  def has_some_year? # is there a year or stated year?
    return false if year.blank? && stated_year.blank?
    true
  end

  # @return [Integer]
  #  The effective year of publication as per nomenclatural rules
  def nomenclature_year
    cached_nomenclature_date.year
  end

  #  Month handling allows values from bibtex like 'may' to be handled
  # @return [Time]
  def nomenclature_date
    Utilities::Dates.nomenclature_date(day, Utilities::Dates.month_index(month), year)
  end

  # @return [Date || Time] <sigh>
  #  An memoizer, getter for cached_nomenclature_date, computes if not .persisted?
  def cached_nomenclature_date
    if !persisted?
      nomenclature_date
    else
      read_attribute(:cached_nomenclature_date)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # @return [BibTeX::Entry, false]
  #   !! Entry equivalent to self, this should round-trip with no changes.
  def to_bibtex
    return false if bibtex_type.nil?
    b = BibTeX::Entry.new(bibtex_type: bibtex_type)

    ::BIBTEX_FIELDS.each do |f|
      next if f == :bibtex_type
      v = send(f)
      if !v.blank?
        b[f] = v
      end
    end

    b.year = year_with_suffix if !year_suffix.blank?

    b[:keywords] = verbatim_keywords unless verbatim_keywords.blank?
    b[:note] = concatenated_notes_string if !concatenated_notes_string.blank?

    unless serial.nil?
      b[:journal] = serial.name
      issns  = serial.identifiers.where(type: 'Identifier::Global::Issn')
      unless issns.empty?
        b[:issn] = issns.first.identifier # assuming the serial has only 1 ISSN
      end
    end

    unless serial.nil?
      b[:journal] = serial.name
      issns = serial.identifiers.where(type: 'Identifier::Global::Issn')
      unless issns.empty?
        b[:issn] = issns.first.identifier # assuming the serial has only 1 ISSN
      end
    end

    uris = identifiers.where(type: 'Identifier::Global::Uri')
    unless uris.empty?
      b[:url] = uris.first.identifier # TW only allows one URI per object
    end

    isbns = identifiers.where(type: 'Identifier::Global::Isbn')
    unless isbns.empty?
      b[:isbn] = isbns.first.identifier # TW only allows one ISBN per object
    end

    dois = identifiers.where(type: 'Identifier::Global::Doi') #.of_type(:isbn)
    unless dois.empty?
      b[:doi] = dois.first.identifier # TW only allows one DOI per object
    end

    # Overiden by `author` and `editor` if present
    b.author = get_bibtex_names('author') if author_roles.load.any? # unless (!authors.load.any? && author.blank?)
    b.editor = get_bibtex_names('editor') if editor_roles.load.any? # unless (!editors.load.any? && editor.blank?)

    # TODO: use global_id or replace with UUID or DOI if available
    b.key = id unless new_record?
    b
  end

  # @return Hash
  #   a to_citeproc with values updated for literal
  #   handling via `{}` in TaxonWorks
  def to_citeproc(normalize_names = true)
    b = to_bibtex
    ::TaxonWorks::Vendor::BibtexRuby.namecase_bibtex_entry(b) if normalize_names

    a = b.to_citeproc

    ::BIBTEX_FIELDS.each do |f|
      next if f == :bibtex_type
      v = send(f)
      if !v.blank? && (v =~ /\A{(.*)}\z/)
        a[f.to_s] = {literal: $1}
      end
    end
    a
  end

  # @return [String, nil]
  #  priority is Person, string
  #  !! Not the cached value !!
  def get_author
    a = authors.load
    if a.any?
      get_bibtex_names('author')
    else
      author.blank? ? nil : author
    end
  end

  # @return [BibTex::Bibliography]
  #   initialized with this Source as an entry
  def bibtex_bibliography
    TaxonWorks::Vendor::BibtexRuby.bibliography([self])
 end

  # @param [String] style
  # @param [String] format
  # @return [String]
  #   this source, rendered in the provided CSL style, as text
  def render_with_style(style = 'vancouver', format = 'text', normalize_names = true)
    s = ::TaxonWorks::Vendor::BibtexRuby.get_style(style)
    cp = CiteProc::Processor.new(style: s, format: format)
    b = to_bibtex
    ::TaxonWorks::Vendor::BibtexRuby.namecase_bibtex_entry(b) if normalize_names
    cp.import( [to_citeproc(normalize_names)] )
    cp.render(:bibliography, id: cp.items.keys.first).first.strip
  end

  # @param [String] format
  # @return [String]
  #   a full representation, using bibtex
  # String must be length > 0
  def cached_string(format = 'text')
    return nil unless (format == 'text') || (format == 'html')
    str = render_with_style(DEFAULT_CSL_STYLE, format)
    str.sub('(0ADAD)', '') # citeproc renders year 0000 as (0ADAD)
  end

  # @return [String, nil]
  #   last names formatted as displayed in nomenclatural authority (iczn), prioritizes
  #   normalized People before BibTeX `author`
  #   !! This is NOT a legal BibTeX format  !!
  def authority_name(reload = true)
    reload ? authors.reload : authors.load
    if !authors.any? # no normalized people, use string, !! not .any? because of in-memory setting?!
      if author.blank?
        return nil
      else
        b = to_bibtex
        ::TaxonWorks::Vendor::BibtexRuby.namecase_bibtex_entry(b)
        return Utilities::Strings.authorship_sentence(b.author.tokens.collect{ |t| t.last })
      end
    else # use normalized records
      return Utilities::Strings.authorship_sentence(authors.collect{ |a| a.full_last_name })
    end
  end

  protected

  def validate_year_suffix
    a = get_author
    unless year_suffix.blank? || year.blank? || a.blank?
      if new_record?
        s = Source.where(author: a, year: year, year_suffix: year_suffix).first
      else
        s = Source.where(author: a, year: year, year_suffix: year_suffix).not_self(self).first
      end
      errors.add(:year_suffix, " '#{year_suffix}' is already used for #{a} #{year}") unless s.nil?
    end
  end

  def italics_are_paired
    l = title.scan('<i>')&.count
    r = title.scan('</i>')&.count
    errors.add(:title, 'italic markup is not paired') unless l == r
  end

  # @param [String] type either `author` or `editor`
  # @return [String]
  #   The BibTeX version of the name strings created from People
  #   BibTeX format is 'lastname, firstname and lastname, firstname and lastname, firstname'
  #   This only references People, i.e. `authors` and `editors`.
  #   !! Do not adapt to reference the BibTeX attributes `author` or `editor`
  def get_bibtex_names(role_type)
    # so, we can not reload here
    send("#{role_type}s").collect{ |a| a.bibtex_name}.join(' and ')
  end

  # @return [Ignored]
  def create_authors
    begin
      Person.transaction do
        authors_to_create.each do |shs|
          p = Person.create!(shs)
          author_roles.build(person: p)
        end
      end
    rescue
      errors.add(:base, 'invalid author parameters')
    end
  end

  # TODO: Replace with taxonworks.csl.  Move unsupported fields to
  # wrappers in vue rendering.
  # set cached values and copies active record relations into bibtex values
  # @return [Ignored]
  def set_cached
    if errors.empty?
      attributes_to_update = {}

      attributes_to_update[:author] = get_bibtex_names('author') if authors.reload.size > 0
      attributes_to_update[:editor] = get_bibtex_names('editor') if editors.reload.size > 0

      c = cached_string('html') # preserves our convention of <i>

      if bibtex_type == 'book' && !pages.blank?
        if pages.to_i.to_s == pages
          c = c + " #{pages} pp."
        else
          c = c + " #{pages}"
        end
      end

      n = []
      n += [stated_year.to_s] if stated_year && year && stated_year != year
      n += ['in ' + Language.find(language_id).english_name.to_s] if language_id
      n += [note.to_s] if note

      c = c + " [#{n.join(', ')}]" unless n.empty?

      attributes_to_update.merge!(
        cached: c,
        cached_nomenclature_date: nomenclature_date,
        cached_author_string: authority_name(false)
      )

      update_columns(attributes_to_update)
    end
  end

  #region hard validations

  # must have at least one of the required fields (TW_REQUIRED_FIELDS)
  # @return [Ignored]
  def check_has_field
    valid = false
    TW_REQUIRED_FIELDS.each do |i|
      if !self[i].blank?
        valid = true
        break
      end
    end
    #TODO This test for auth doesn't work with a new record.
    if (self.authors.count > 0 || self.editors.count > 0 || !self.serial.nil?)
      valid = true
    end
    if !valid
      errors.add(
        :base,
        'Missing core data. A TaxonWorks source must have one of the following: author, editor, booktitle, title, url, journal, year, or stated year'
      )
    end
  end

end

