require 'citeproc'
require 'csl/styles'

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
#   Bibtex has month.
#
#   Bibtex does not have day.
#
# TW will add all non-standard or housekeeping attributes to the bibliography even though
# the data may be ignored.
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
#   @return[String] the name of the journal (serial) associated with this source
#   @return [nil] means the attribute is not stored in the database.
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
#   @todo
#
# @!attribute url
#   @return [String]
#   A TW required attribute for certain bibtex_types (TW requires a value in one of the required attributes.)
#
# @!attribute author
#   @return [String] the list of author names in BibTeX format
#   @return [nil] means the attribute is not stored in the database.
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of any of the required attributes.)
#   The name(s) of the author(s), in the format described in the LaTeX book. Names should be formatted as
#   "Last name, FirstName MiddleName". FirstName and MiddleName can be initials. If there are multiple authors,
#   each author name should be separated by the word " and ". It should be noted that all the names before the
#   comma are treated as a single last name.
#
class Source::Bibtex < Source

  attr_accessor :authors_to_create

  # @todo :update_authors_editor_if_changed? if: Proc.new { |a| a.password.blank? }

  # TW required fields (must have one of these fields filled in)
  # either year or stated_year is acceptable
  TW_REQUIRED_FIELDS = [:author, :editor, :booktitle, :title, :url, :journal, :year, :stated_year].freeze

  IGNORE_SIMILAR = [:verbatim, :cached, :cached_author_string, :cached_nomenclature_date].freeze
  IGNORE_IDENTICAL = IGNORE_SIMILAR.dup.freeze

  belongs_to :serial, inverse_of: :sources
  belongs_to :source_language, class_name: 'Language', foreign_key: :language_id, inverse_of: :sources
  # above to handle clash with bibtex language field.

  has_many :author_roles, -> { order('roles.position ASC') }, class_name: 'SourceAuthor',
           as: :role_object, validate: true
  has_many :authors, -> { order('roles.position ASC') },
           through: :author_roles, source: :person, validate: true
  has_many :editor_roles, -> { order('roles.position ASC') }, class_name: 'SourceEditor',
           as: :role_object, validate: true # ditto for self.editor & self.editors
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

  # @todo refactor out date validation methods so that they can be unified (TaxonDetermination, CollectingEvent)
  validates :year, date_year: {min_year: 1000, max_year: Time.now.year + 2,
                               message:  'must be an integer greater than 999 and no more than 2 years in the future'}

  validates_presence_of :month,
                        unless:  -> { day.blank? },
                        message: 'is required when day is provided'

  validates_inclusion_of :month,
                         in: ::VALID_BIBTEX_MONTHS,
                         allow_blank: true,
                         message: ' month'

  validates :day, date_day: {year_sym: :year, month_sym: :month},
            unless: -> { year.blank? || month.blank? }

  validates :url, format:                                   {
    with:    URI::regexp(%w(http https ftp)),
    message: '[%{value}] is not a valid URL'}, allow_blank: true

  # includes nil last, exclude it explicitly with another condition if need be
  scope :order_by_nomenclature_date, -> { order(:cached_nomenclature_date) }

  soft_validate(:sv_has_some_type_of_year, set: :recommended_fields)
  soft_validate(:sv_contains_a_writer, set: :recommended_fields)
  soft_validate(:sv_has_title, set: :recommended_fields)
  soft_validate(:sv_is_article_missing_journal, set: :recommended_fields)
  soft_validate(:sv_missing_required_bibtex_fields, set: :bibtex_fields)

  #region ruby-bibtex related

  # @return [Array] journal, nil or name
  def journal
    [read_attribute(:journal), (self.serial.blank? ? nil : self.serial.name)].compact.first
  end

  # @return [String]
  def verbatim_journal
    read_attribute(:journal)
  end

  # rubocop:disable Metrics/MethodLength
  # @return [BibTeX::Entry]
  #   entry equivalent to self
  def to_bibtex
    b = BibTeX::Entry.new(bibtex_type: self[:bibtex_type])
    ::BIBTEX_FIELDS.each do |f|
      if (!self.send(f).blank?) && !(f == :bibtex_type)
        b[f] = self.send(f)
      end
    end

    if !self.year_suffix.blank?
      b.year = self.year_with_suffix
    end

    unless self.verbatim_keywords.blank?
      b[:keywords] = self.verbatim_keywords
    end

    b[:note] = concatenated_notes_string if !concatenated_notes_string.blank? # see Notable
    unless self.serial.nil?
      b[:journal] = self.serial.name
      issns       = self.serial.identifiers.where(type: 'Identifier::Global::Issn') # of_type(:issn)
      unless issns.empty?
        b[:issn] = issns.first.identifier # assuming the serial has only 1 ISSN
      end
    end

    unless self.serial.nil?
      b[:journal] = self.serial.name
      issns       = self.serial.identifiers.where(type: 'Identifier::Global::Issn') # .of_type(:issn)
      unless issns.empty?
        b[:issn] = issns.first.identifier # assuming the serial has only 1 ISSN
      end
    end

    uris = self.identifiers.where(type: 'Identifier::Global::Uri') # of_type(:uri)
    unless uris.empty?
      b[:url] = uris.first.identifier # TW only allows one URI per object
    end

    isbns = self.identifiers.where(type: 'Identifier::Global::Isbn') #.of_type(:isbn)
    unless isbns.empty?
      b[:isbn] = isbns.first.identifier # TW only allows one ISBN per object
    end

    dois = self.identifiers.where(type: 'Identifier::Global::Doi') #.of_type(:isbn)
    unless dois.empty?
      b[:doi] = dois.first.identifier # TW only allows one DOI per object
    end

    b.author = self.compute_bibtex_names('author') unless (!self.authors.any? && self.author.blank?)
    b.editor = self.compute_bibtex_names('editor') unless (!self.editors.any? && self.editor.blank?)

    b.key    = self.id unless self.new_record?
    b
  end

  # rubocop:enable Metrics/MethodLength

  # @param [String] type either `author` or `editor`
  # @return [String]
  #   the bibtex version of the name strings created from the TW people
  #   BibTeX format is 'lastname, firstname and lastname,firstname and lastname, firstname'
  #   For a name list not joined by multiple 'and's, use compute_human_names
  def compute_bibtex_names(type)
    method  = type
    methods = type + 's'
    case self.send(methods).size
      when 0
        return self.send(method)
      when 1
        return self.send(methods).first.bibtex_name
      else
        return self.send(methods).collect { |a| a.bibtex_name }.join(' and ')
    end
  end

  # @param [String] type either `author` or `editor`
  # @return [String]
  #   A human readable version of the person list
  #   'firstname lastname, firstname lastname, & firstname lastname'
  #  TODO: DEPRECATE
  def compute_human_names(type)
    method  = type
    methods = type + 's'
    case self.send(methods).size
      when 0
        return self.send(method)
      when 1
        return self.send(methods).first.name
      else
        return self.send(methods).collect { |a| a.name }.to_sentence(last_word_connector: ' & ')
    end
  end

  # @return [Boolean]
  #   whether the BibTeX::Entry representation of this source is valid
  def valid_bibtex?
    self.to_bibtex.valid?
  end

  # @return [BibTeX::Entry]
  def self.new_from_bibtex_text(text = nil)
    a = BibTeX.parse(text).convert(:latex).first
    new_from_bibtex(a)
  end

  # Instantiates a Source::Bibtex instance from a BibTeX::Entry
  # Note: note conversion is handled in note setter.
  #       identifiers are handled in associated setter.
  # !! Unrecognized attributes are added as import attributes.
  #
  # Usage:
  #    a = BibTeX::Entry.new(bibtex_type: 'book', title: 'Foos of Bar America', author: 'Smith, James', year: 1921)
  #    b = Source::Bibtex.new(a)
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

  # @return [String] A string that represents the year with suffix as seen in a BibTeX bibliography.
  #   returns "" if neither :year or :year_suffix are set.
  def year_with_suffix
    self[:year].to_s + self[:year_suffix].to_s
  end

  # @return [String] A string that represents the authors last_names and year (no suffix)
  def author_year
    return 'not yet calculated' if self.new_record?
    [cached_author_string, year].compact.join(', ')
  end

  # rubocop:disable Metrics/MethodLength
  # Modified from build, the issues with polymorphic has_many and build
  # are more than we want to tackle right now
  # @return [Array, Boolean] of names, or false
  def create_related_people_and_roles
    return false if !self.valid? ||
      self.new_record? ||
      (self.author.blank? && self.editor.blank?) ||
      self.roles.count > 0

    bibtex = to_bibtex
    bibtex.parse_names

    begin
      Role.transaction do
        unless bibtex.authors.blank?
          bibtex.authors.each do |a|
            p = Source::Bibtex.bibtex_author_to_person(a)
            p.save!
            SourceAuthor.create!(role_object: self, person: p)
          end
        end

        unless bibtex.editors.blank?
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

  # rubocop:enable Metrics/MethodLength

  # @param [BibTeX::Name] bibtex_author
  # @return [Person, Boolean] new person, or false
  def self.bibtex_author_to_person(bibtex_author)
    return false if bibtex_author.class != BibTeX::Name
    Person.new(
      first_name: bibtex_author.first,
      prefix:     bibtex_author.prefix,
      last_name:  bibtex_author.last,
      suffix:     bibtex_author.suffix)
  end

  # @todo create related Serials

  #endregion ruby-bibtex related

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
    identifiers.where(type: type_value).first.try(:identifier)
  end

 #endregion getters & setters

  # @return [Boolean]
  def has_authors? # is there a bibtex author or author roles?
    return true if !(author.blank?) # author attribute is empty
    return false if new_record? # nothing saved yet, so no author roles are saved yet
    # self exists in the db
    (self.authors.count > 0) ? (return true) : (return false)
  end

  # @return [Boolean]
  def has_editors?
    return true if !(self.editor.blank?)
    # editor attribute is empty
    return false if self.new_record?
    # self exists in the db
    (self.editors.count > 0) ? (return true) : (return false)
  end

  # @return [Boolean]
  def has_writer? # contains either an author or editor
    (has_authors?) || (has_editors?) ? true : false
  end

  # @return [Boolean]
  def has_some_year? # is there a year or stated year?
    return true if !(self.year.blank?) || !(self.stated_year.blank?)
    false
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

  # @return [Date]
  #  An memoizer, getter for cached_nomenclature_date, computes if not .persisted?
  def cached_nomenclature_date
    if !persisted?
      nomenclature_date
    else
      read_attribute(:cached_nomenclature_date)
    end
  end

  # @return [String, nil]
  #   last names formatted as displayed in nomenclatural authority (iczn), prioritizes
  #   normalized people records before bibtex author string
  def authority_name
    if !authors.reload.any? # no normalized people, use string, !! not .any? because of in-memory setting?!
      if author.blank?
        return nil
      else
        b = to_bibtex
        b.parse_names
        return Utilities::Strings.authorship_sentence(b.author.tokens.collect { |t| t.last })
      end
    else # use normalized records
      return Utilities::Strings.authorship_sentence(authors.reload.collect { |a| a.full_last_name })
    end
  end

  # @return [BibTex::Bibliography]
  #   initialized with this source as an entry
  def bibtex_bibliography
    bx_entry = to_bibtex
    bx_entry.year = '0000' if bx_entry.year.blank? # cludge to fix render problem with year
    b = BibTeX::Bibliography.new
    b.add(bx_entry)
    b
  end

  def bibtex_bibliography_for_zootaxa
    bx_entry = to_bibtex
    bx_entry.year = '0000' if bx_entry.year.blank? # cludge to fix render problem with year
    v = self.volume
    v = v + '(' + self.number + ')' unless self.number.blank?
    v = [self.stated_year, v].compact.join(', ') if !self.stated_year.blank? and self.stated_year != self.year
    bx_entry.volume = v if !v.blank? && bx_entry.try(:volume) && bx_entry.volume != v
    b = BibTeX::Bibliography.new
    b.add(bx_entry)
    b
  end

  # @param [String] style
  # @param [String] format
  # @return [String]
  #   this source, rendered in the provided CSL style, as text
  def render_with_style(style = 'vancouver', format = 'text')
    cp = CiteProc::Processor.new(style: style, format: format)
    cp.import(bibtex_bibliography.to_citeproc)
    # if style == 'zootaxa'
    #   cp.import(bibtex_bibliography_for_zootaxa.to_citeproc)
    # else
    #   cp.import(bibtex_bibliography.to_citeproc)
    # end
    #name = cp.engine.style.macros['author'] > 'names' > 'name'
    #name[:initialize] = 'false'

    cp.render(:bibliography, id: cp.items.keys.first).first.strip
  end

  # @param [String] format
  # @return [String]
  #   a full representation, using bibtex
  # String must be length > 0
  #
  # There (was) a problem with the zootaxa format and letters!
  #  https://github.com/citation-style-language/styles/pull/2305
  def cached_string(format = 'text')
    return nil unless (format == 'text') || (format == 'html')
    str = render_with_style('zootaxa', format) # the current TaxonWorks default ... make a constant
    str.sub('(0ADAD)', '') # citeproc renders year 0000 as (0ADAD)
  end

  protected

  # @return [Ignored]
  def create_authors
    begin
      Person.transaction do
        authors_to_create.each do |shs|
          p = Person.create!(shs)
          self.author_roles.build(person: p)
        end
      end
    rescue
      errors.add(:base, 'invalid author parameters')
    end
  end

  # set cached values and copies active record relations into bibtex values
  # @return [Ignored]
  def set_cached
    if errors.empty?
      attributes_to_update = {
        cached: cached_string('text'),
        cached_nomenclature_date: nomenclature_date,
        cached_author_string: authority_name
      }

      attributes_to_update[:author] = compute_bibtex_names('author') if author.blank? && authors.size > 0
      attributes_to_update[:editor] = compute_bibtex_names('editor') if editor.blank? && editors.size > 0

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

  #endregion  hard validations

  #region Soft_validation_methods
  # @return [Ignored]
  def sv_has_authors
    # only used in validating BibTeX output
    if !(has_authors?)
      soft_validations.add(:author, 'Valid BibTeX requires an author with this type of source.')
    end
  end

  # @return [Ignored]
  def sv_contains_a_writer # neither author nor editor
    if !has_writer?
      soft_validations.add(:base, 'There is neither author, nor editor associated with this source.')
    end
  end

  # @return [Ignored]
  def sv_has_title
    if title.blank?
      unless soft_validations.messages.include?('There is no title associated with this source.')
        soft_validations.add(:title, 'There is no title associated with this source.')
      end
    end
  end

  # @return [Ignored]
  def sv_has_some_type_of_year
    if !has_some_year?
      soft_validations.add(:base, 'There is no year nor is there a stated year associated with this source.')
    end
  end

  # @return [Ignored]
  def sv_year_exists
    # only used in validating BibTeX output
    if year.blank?
      soft_validations.add(:year, 'Valid BibTeX requires a year with this type of source.')
    elsif year < 1700
      soft_validations.add(:year, 'This year is prior to the 1700s')
    end
  end

  # def sv_missing_journal
  # never used
  #   soft_validations.add(:bibtex_type, 'The source is missing a journal name.') if self.journal.blank?
  # end

  # @return [Ignored]
  def sv_is_article_missing_journal
    if bibtex_type == 'article'
      if journal.blank? and serial.blank?
        soft_validations.add(:bibtex_type, 'This article is missing a journal name or serial.')
      end
    end
  end

  # @return [Ignored]
  def sv_has_a_publisher
    if publisher.blank?
      soft_validations.add(:publisher, 'Valid BibTeX requires a publisher to be associated with this source.')
    end
  end

  # @return [Ignored]
  def sv_has_booktitle
    if booktitle.blank?
      soft_validations.add(:booktitle, 'Valid BibTeX requires a book title to be associated with this source.')
    end
  end

  # @return [Ignored]
  def sv_is_contained_has_chapter_or_pages
    if chapter.blank? && pages.blank?
      soft_validations.add(:bibtex_type, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')
      # soft_validations.add(:chapter, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')
      # soft_validations.add(:pages, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')
    end
  end

  # @return [Ignored]
  def sv_has_school
    if school.blank?
      soft_validations.add(:school, 'Valid BibTeX requires a school associated with any thesis.')
    end
  end

  # @return [Ignored]
  def sv_has_institution
    if institution.blank?
      soft_validations.add(:institution, 'Valid BibTeX requires an institution with a tech report.')
    end
  end

  # @return [Ignored]
  def sv_has_note
    if (note.blank?) && (!notes.any?)
      soft_validations.add(:note, 'Valid BibTeX requires a note with an unpublished source.')
    end
  end

  # rubocop:disable Metrics/MethodLength
  # @return [Ignored]
  def sv_missing_required_bibtex_fields
    case bibtex_type
      when 'article' #:article       => [:author,:title,:journal,:year]
        sv_has_authors
        sv_has_title
        sv_is_article_missing_journal
        sv_year_exists
      when 'book' #:book          => [[:author,:editor],:title,:publisher,:year]
        sv_contains_a_writer
        sv_has_title
        sv_has_a_publisher
        sv_year_exists
      when 'booklet' #    :booklet       => [:title],
        sv_has_title
      when 'conference' #    :conference    => [:author,:title,:booktitle,:year],
        sv_has_authors
        sv_has_title
        sv_has_booktitle
        sv_year_exists
      when 'inbook' #    :inbook        => [[:author,:editor],:title,[:chapter,:pages],:publisher,:year],
        sv_contains_a_writer
        sv_has_title
        sv_is_contained_has_chapter_or_pages
        sv_has_a_publisher
        sv_year_exists
      when 'incollection' #    :incollection  => [:author,:title,:booktitle,:publisher,:year],
        sv_has_authors
        sv_has_title
        sv_has_booktitle
        sv_has_a_publisher
        sv_year_exists
      when 'inproceedings' #    :inproceedings => [:author,:title,:booktitle,:year],
        sv_has_authors
        sv_has_title
        sv_has_booktitle
        sv_year_exists
      when 'manual' #    :manual        => [:title],
        sv_has_title
      when 'mastersthesis' #    :mastersthesis => [:author,:title,:school,:year],
        sv_has_authors
        sv_has_title
        sv_has_school
        sv_year_exists
      #    :misc          => [],  (no required fields)
      when 'phdthesis' #    :phdthesis     => [:author,:title,:school,:year],
        sv_has_authors
        sv_has_title
        sv_has_school
        sv_year_exists
      when 'proceedings' #    :proceedings   => [:title,:year],
        sv_has_title
        sv_year_exists
      when 'techreport' #    :techreport    => [:author,:title,:institution,:year],
        sv_has_authors
        sv_has_title
        sv_has_institution
        sv_year_exists
      when 'unpublished' #    :unpublished   => [:author,:title,:note]
        sv_has_authors
        sv_has_title
        sv_has_note
    end
  end
  # rubocop:enable Metrics/MethodLength
  #endregion   Soft_validation_methods
end

