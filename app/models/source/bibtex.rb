require 'citeproc'
require 'csl/styles'

# @author Elizabeth Frank <eef@illinois.edu> INHS University of IL
# @author Matt Yoder 
# 
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
# [REQUIRED] Omitting the field will produce a warning message and, rarely, a badly formatted bibliography entry.
# If the required information is not
#       meaningful, you are using the wrong entry type. However, if the required
#       information is meaningful but, say, already included is some other field,
#       simply ignore the warning.
# [OPTIONAL] The field's information will be used if present, but can be omitted
#  without causing any formatting problems. You should include the optional
#       field if it will help the reader.
# [IGNORED] The field is ignored. BibTEX ignores any field that is not required or
#optional, so you can include any fields you want in a bib file entry. It's a
#       good idea to put all relevant information about a reference in its bib file
#       entry - even information that may never appear in the bibliography.
#
# TW will add all non-standard or housekeeping attributes to the bibliography even though
# the data may be ignored.
#
# @!group non-Bibtex attributes that are cross-referenced.
#
# @!attribute serial_id [Fixnum]
#   @note not yet implemented!
#   @return [Fixnum] the unique identifier of the serial record in the Serial? table.
#   @return [nil] means the record does not exist in the database.
#
# @!attribute verbatim
# @!attribute cached
# @!attribute cached_author_string
#
#
# @!endgroup
#
#
#                                                       #
#                                                       #
# @!group BibTeX attributes (based on BibTeX fields)    #
#                                                       #
#
# @!attribute address
#   BibTeX standard field (optional for types: book, inbook, incollection, inproceedings, manual, mastersthesis,
#   phdthesis, proceedings, techreport)
#   Usually the address of the publisher or other type of institution.
#   For major publishing houses, van Leunen recommends omitting the information
#   entirely. For small publishers, on the other hand, you can help the reader by giving the complete address.
#   @return [#String] the address
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute annote
#   BibTeX standard field (ignored by standard processors)
#   An annotation. It is not used by the standard bibliography styles, but
#   may be used by others that produce an annotated bibliography.
#   (compare to a note which is any additional information which may be useful to the reader)
#   In most cases these are personal annotations; TW will translate these into notes with a specified project so
#   they will only be visible within the project where the note was made. <== Under debate with Matt.
#   @return [String] the annotation
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute author
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of any of the required attributes.)
#   The name(s) of the author(s), in the format described in the LaTeX book. Names should be formatted as
#   "Last name, FirstName MiddleName". FirstName and MiddleName can be initials. If there are multiple authors,
#   each author name should be separated by the word " and ". It should be noted that all the names before the
#   comma are treated as a single last name.
#   @return [String] the list of author names in BibTeX format
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute editor
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of any of the required attributes.)
#   The name(s) of the editor(s), in the format described in the LaTeX book. Names should be formatted as
#   "Last name, FirstName MiddleName". FirstName and MiddleName can be initials. If there are multiple editors,
#   each editor name should be separated by the word " and ". It should be noted that all the names before the
#   comma are treated as a single last name.
#
#   If there is also an author field, then the editor field gives the editor of the book or collection in
#   which the reference appears.
#   @return [String] the list of editor names in BibTeX format
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute booktitle
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of the required attributes.)
#   Title of a book, part of which is being cited. See the LaTEX book for how to type titles.
#   For book entries, use the title field instead.
#   @return[String] the title of the book
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute chapter
#   BibTeX standard field (required for types: )(optional for types:)
#   A chapter (or section or whatever) number.
#   @return [String] the chapter or section number.
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute crossref
#   BibTeX standard field (ignored by standard processors)
#   The database key(key attribute) of the entry being cross referenced.
#   This attribute is only set (and saved) during the import process, and is only relevant
#   in a specific bibliography.
#   @return[String] the key of the cross referenced source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute edition
#   BibTeX standard field (required for types: )(optional for types:)
#   The edition of a book(for example, "Second"). This should be an ordinal, and should
#   have the first letter capitalized, as shown here;
#   the standard styles convert to lower case when necessary.
#   @return[String] the edition of the book
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute howpublished
#   BibTeX standard field (required for types: )(optional for types:)
#   How something unusual has been published. The first word should be capitalized.
#   @return[String] a description of how this source was published
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute institution
#   BibTeX standard field (required for types: )(optional for types:)
#   The sponsoring institution of a technical report
#   @return[String] the name of the institution publishing this source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute journal
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required attribute (TW requires a value in one of the required attributes.)
#   A journal name. Many BibTeX processors have standardized abbreviations for many journals
#   which would be listed in your local BibTeX processor guide. Once this attribute has been
#   normalized against TW Serials, this attribute will contain the full journal name as
#   defined by the Serial object. If you want a preferred abbreviation associated with
#   with this journal, add the abbreviation the serial object.
#   @return[String] the name of the journal (serial) associated with this source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute key
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
#
# Dates in Source Bibtex.
# It is common for there two be two (or more) dates associated with the origin of a source.
# 1) If you only have reference to a single value, it goes in year (month, day)
# 2) If you have reference to two year values, the actual year of publication goes in year, and
# the stated year of publication goes in stated_year. 
# 3) If you have month or day publication, they go in month or day.
#
# We do not track stated_month or stated_day if
# they are present in addition to actual month and actual day.
#
#
# Bibtex has month
#  
# Bibtex does not have day.
#
# @!attribute month
#   the actual publication month. a BibTeX standard field (required for types: ) (optional for types:)
#   The month in which the work was published or, for an unpublished work, in which it was written.
#   It should use the standard three-letter abbreviation, as described in Appendix B.1.3 of the LaTeX book.
#   The three-letter lower-case abbreviations are available in _BibTeX::MONTHS_.
#   If month is present there must be a year.
#   @return[String] The three-letter lower-case abbreviation for the month in which this source was published.
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute day 
#   the actual publication month, NOT a BibTex standard field
#   If day is present there must be a month and day must be valid for the month.
#
# @!attribute year 
#   the actual publication year. a BibTeX standard field (required for types: ) (optional for types:)
#   A TW required attribute (TW requires a value in one of the required attributes.)
#   Year must be between 1000 and now + 2 years inclusive
#   
# @!attribute stated_year
#
# @!attribute cached_nomenclature_date
#   @return 
#
# @!attribute note
#   BibTeX standard field (required for types: unpublished)(optional for types:)
#   Any additional information that can help the reader. The first word should be capitalized.
#
#   This attribute is used on import, but is otherwise ignored.   Updates to this field are
#   NOT transferred to the associated TW note and not added to any export.  TW does NOT allow '|' within a note. (\'s
#   are used to separate multiple TW notes associated with a single object on import)
#   @return[String] the BibTeX note associated with this source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute number
#   BibTeX standard field (required for types: )(optional for types:)
#   The number of a journal, magazine, technical report, or of a work in a series.
#   An issue of a journal or magazine is usually identified by its volume and number;
#   the organization that issues a technical report usually gives it a number;
#   and sometimes books are given numbers in a named series.
#
#   This attribute is equivalent to the Species File reference issue.
#   @return[String] the number in a series, issue or technical report number associated with this source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute organization
#   BibTeX standard field (required for types: )(optional for types:)
#   The organization that sponsors a conference or that publishes a manual.
#   @return[String] the organization associated with this source
#   @return [nil] means the attribute is not stored in the database.
#
# @!attribute pages
#   BibTeX standard field (required for types: )(optional for types:)
#   One or more page numbers or range of numbers, such as 42--111 or
#   7,41,73--97 or 43+ (the `+' in this last example indicates pages following
#   that don't form a simple range). To make it easier to maintain Scribe-
#   compatible databases, the standard styles convert a single dash (as in
#   7-33) to the double dash used in TeX to denote number ranges (as in 7--33).
#
#  #!! TODO: What is address ?
# @!attribute publisher
# @!attribute school
# @!attribute series
# @!attribute title
#   A TW required attribute (TW requires a value in one of the required attributes.)
# @!attribute type
# @!attribute translator - not yet implemented
#   bibtex-ruby gem supports translator, it's not clear whether TW will or not.
# @!attribute volume

# @!attribute URL
#   A TW required attribute (TW requires a value in one of the required attributes.)
# @!attribute doi - not implemented yet
#   Used by bibtex-ruby gem method identifier
# @!attribute ISBN
#   Used by bibtex-ruby gem method identifier
# @!attribute ISSN
#   Used by bibtex-ruby gem method identifier
# @!attribute LCCN
# @!attribute abstract
# @!attribute keywords
# @!attribute price
# @!attribute copyright
# @!attribute language
# @!attribute contents
#
#
#
#
# @!endgroup
#
# UNKNOWN:
#
# @!attribute bibtex_type
#
#
class Source::Bibtex < Source
  include SoftValidation

  attr_accessor :authors_to_create

  # TODO :update_authors_editor_if_changed? if: Proc.new { |a| a.password.blank? }

  # TW required fields (must have one of these fields filled in)
  TW_REQUIRED_FIELDS = [
    :author,
    :editor,
    :booktitle,
    :title,
    :url,
    :journal,
    :year,
    :stated_year
  ] # either year or stated_year is acceptable

  belongs_to :serial, inverse_of: :sources
  belongs_to :source_language, class_name: "Language", foreign_key: :language_id, inverse_of: :sources
  # above to handle clash with bibtex language field.

  has_many :author_roles, -> { order('roles.position ASC') }, class_name: 'SourceAuthor', as: :role_object, validate: true
  has_many :authors, -> { order('roles.position ASC') }, through: :author_roles, source: :person, validate: true # self.author & self.authors should match or one of them should be empty
  has_many :editor_roles, -> { order('roles.position ASC') }, class_name: 'SourceEditor', as: :role_object, validate: true # ditto for self.editor & self.editors
  has_many :editors, -> { order('roles.position ASC') }, through: :editor_roles, source: :person, validate: true
  accepts_nested_attributes_for :authors, :editors, :author_roles, :editor_roles, allow_destroy: true
  # accepts_nested_attributes_for :authors, :editors, :author_roles, :editor_roles, reject_if: :all_blank, allow_destroy: true

  before_validation :create_authors, if: '!authors_to_create.nil?'
  before_validation :check_has_field
  before_save :set_cached_nomenclature_date

  #region validations
  validates_inclusion_of :bibtex_type,
                         in:      ::VALID_BIBTEX_TYPES,
                         message: '%{value} is not a valid source type'

  validates_presence_of :year,
                        if:      '!month.blank? || !stated_year.blank?',
                        message: 'year is required when month or stated_year is provided'

  # TODO: refactor out date validation methods so that they can be unified (TaxonDetermination, CollectingEvent)
  validates_numericality_of :year,
                            only_integer:          true, greater_than: 999,
                            less_than_or_equal_to: Time.now.year + 2,
                            allow_blank:           true,
                            message:               'year must be an integer greater than 999 and no more than 2 years in the future'

  validates_presence_of :month,
                        if:      '!day.nil?',
                        message: 'month is required when day is provided'

  validates_inclusion_of :month,
                         in:          ::VALID_BIBTEX_MONTHS,
                         allow_blank: true,
                         message:     ' month'

  validates_numericality_of :day,
                            allow_blank:           true,
                            only_integer:          true,
                            greater_than:          0,
                            less_than_or_equal_to: Proc.new { |a| Time.utc(a.year, a.month).end_of_month.day },
                            :unless                => 'year.nil? || month.nil?',
                            message:               '%{value} is not a valid day for the month provided'

  validates :url, :format => {:with    => URI::regexp(%w(http https ftp)),
                              message: "[%{value}] is not a valid URL"}, allow_blank: true

  #endregion validations

  # includes nil last, exclude it explicitly with another condition if need be
  scope :order_by_nomenclature_date, -> { order(:cached_nomenclature_date) }

  #region soft_validate setup calls
  soft_validate(:sv_has_some_type_of_year, set: :recommended_fields)
  soft_validate(:sv_contains_a_writer, set: :recommended_fields)
  soft_validate(:sv_has_title, set: :recommended_fields)
  soft_validate(:sv_is_article_missing_journal, set: :recommended_fields)
  #  soft_validate(:sv_has_url, set: :recommended_fields) # probably should be sv_has_identifier instead of sv_has_url
  soft_validate(:sv_missing_required_bibtex_fields, set: :bibtex_fields)
  #endregion

  #region ruby-bibtex related

  def journal
    [read_attribute(:journal), (self.serial.blank? ? nil : self.serial.name)].compact.first
  end

  def verbatim_journal
    read_attribute(:journal)
  end

  # @return [BibTeX::Entry]
  #   entry equivalent to self
  def to_bibtex
    b = BibTeX::Entry.new(:bibtex_type => self[:bibtex_type])
    ::BIBTEX_FIELDS.each do |f|
      if (!self.send(f).blank?) && !(f == :bibtex_type)
        b[f] = self.send(f)
      end
    end

    if !self.year_suffix.blank?
      b.year = self.year_with_suffix
    end

    b[:note] = concatenated_notes_string if !concatenated_notes_string.blank? # see Notable
    unless self.serial.nil?
      b[:journal] = self.serial.name
      issns = self.serial.identifiers.of_type(:issn)
      unless issns.empty?
        b[:issn] = issns.first.identifier # assuming the serial has only 1 ISSN
      end
    end

    b.author = self.compute_bibtex_names('author') unless (self.authors.size == 0 && self.author.blank?)
    b.editor = self.compute_bibtex_names('editor') unless (self.editors.size == 0 && self.editor.blank?)

    b.key    = self.id unless self.new_record? # id.blank?
    b
  end

  # @param type [String] either author or editor
  # @return [String]
  #   the bibtex version of the name strings created from the TW people
  # !! TODO: this is an and b/w all people for > 1 person, likely not correct
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


  # TODO add conversion of identifiers to ruby-bibtex fields
  # TODO if it finds one & only one match for serial assigns the serial ID, and if not it just store in journal title
  # serial with alternate_value on name .count = 1 assign .first
  # before validate assign serial if matching & not doesn't have a serial currently assigned.

  # @return [Boolean]
  #   whether the BibTeX::Entry representation of this source is valid
  def valid_bibtex?
    self.to_bibtex.valid?
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
  # @param bibtex_entry [BibTex::Entry] the BibTex::Entry to convert 
  # @return [Source::BibTex.new] a new instance 
  def self.new_from_bibtex(bibtex_entry = nil)
    # TODO On input, convert ruby-bibtex.url to an identifier

    return false if !bibtex_entry.kind_of?(::BibTeX::Entry)
    s                 = Source::Bibtex.new(bibtex_type: bibtex_entry.type.to_s)
    import_attributes = []
    bibtex_entry.fields.each do |key, value|
      if key == :keywords
        s.verbatim_keywords = value
        next
      end
      v = value.to_s.strip
      if s.respond_to?(key.to_sym)
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
    [cached_author_string, year].compact.join(", ")
  end

  # Modified from build, the issues with polymorphic has_many and build
  # are more than we want to tackle right now
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

        if !bibtex.editors.blank?
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

  def self.bibtex_author_to_person(bibtex_author)
    return false if bibtex_author.class != BibTeX::Name
    Person.new(
      first_name: bibtex_author.first,
      prefix:     bibtex_author.prefix,
      last_name:  bibtex_author.last,
      suffix:     bibtex_author.suffix)
  end

  #TODO create related Serials

  #endregion  ruby-bibtex related

  #region getters & setters

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

  def month=(value)
    v = Utilities::Dates::SHORT_MONTH_FILTER[value]
    v = v.to_s if !v.nil?
    write_attribute(:month, v)
  end

  # Used only on import from BibTeX records
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

  # @return [String]
  #   last names formatted as displayed in nomenclatural authority (iczn), prioritizes
  #   normalized people records before bibtex author string
  def authority_name
    if self.authors.count == 0 # no normalized people, use string
      if self.author.blank?
        return ('')
      else
        b = self.to_bibtex
        b.parse_names
        return b.author.tokens.collect { |t| t.last }.to_sentence(last_word_connector: ' & ')
      end
    else # use normalized records 
      return self.authors.collect { |a| a.full_last_name }.to_sentence(last_word_connector: ' & ')
    end
  end

  #region identifiers
  def isbn=(value)
    write_attribute(:isbn, value)
    unless value.blank?
      if tw_isbn = self.identifiers.where(type: 'Identifier::Global::Isbn').first
        if tw_isbn.identifier != value
          tw_isbn.destroy
          self.identifiers.build(type: 'Identifier::Global::Isbn', identifier: value)
        end
      else
        self.identifiers.build(type: 'Identifier::Global::Isbn', identifier: value)
      end
    end
  end

  def isbn
    identifier_string_of_type(:isbn)
  end

  def doi=(value)
    write_attribute(:doi, value)
    unless value.blank?
      if tw_doi = self.identifiers.where(type: 'Identifier::Global::Doi').first
        if tw_doi.identifier != value
          tw_doi.destroy
          self.identifiers.build(type: 'Identifier::Global::Doi', identifier: value)
        end
      else
        self.identifiers.build(type: 'Identifier::Global::Doi', identifier: value)
      end
    end
  end

  def doi
    identifier_string_of_type(:doi)
  end

  # TODO: Are ISSN only Serials now? Maybe - the raw bibtex source may come in with an ISSN in which case
  # we need to set the serial based on ISSN.
  def issn=(value)
    write_attribute(:issn, value)
    unless value.blank?
      if tw_issn = self.identifiers.where(type: 'Identifier::Global::Issn').first
        if tw_issn.identifier != value
          tw_issn.destroy
          self.identifiers.build(type: 'Identifier::Global::Issn', identifier: value)
        end
      else
        self.identifiers.build(type: 'Identifier::Global::Issn', identifier: value)
      end
    end
  end

  def issn
    identifier_string_of_type(:issn)
  end

  # turn bibtex URL field into a Ruby URI object
  def url_as_uri
    URI(self.url) unless self.url.blank?
  end

  # TODO: Turn this into a has_one relationship
  def identifier_string_of_type(type)
    # This relies on the identifier class to enforce a single version of any identifier
    identifiers = self.identifiers.of_type(type)
    identifiers.size == 0 ? nil : identifiers.first.identifier
  end

  #endregion identifiers

  #TODO if language is set => set language_id
  # def language=(value)
  #
  # end
  #endregion getters & setters

  #region has_<attribute>? section
  def has_authors? # is there a bibtex author or author roles?
    return true if !(self.author.blank?) # author attribute is empty
    return false if self.new_record? # nothing saved yet, so no author roles are saved yet
    # self exists in the db
    (self.authors.count > 0) ? (return true) : (return false)
  end

  def has_editors?
    return true if !(self.editor.blank?)
    # editor attribute is empty
    return false if self.new_record?
    # self exists in the db
    (self.editors.count > 0) ? (return true) : (return false)
  end

  def has_writer? # contains either an author or editor
    (has_authors?) || (has_editors?) ? true : false
  end

  def has_some_year? # is there a year or stated year?
    return true if !(self.year.blank?) || !(self.stated_year.blank?)
    false
  end

  #endregion has_<attribute>? section

  #region time/date related

  # An memoizer, getter for cached_nomenclature_date, computes if not .persisted?
  # @return [Date] 
  def date
    set_cached_nomenclature_date if !self.persisted?
    self.cached_nomenclature_date
  end

  # The effective year of publication as per nomenclatural rules.
  # @return [Integer]
  def nomenclature_year
    date.year if date
  end

  def set_cached_nomenclature_date
    self.cached_nomenclature_date = Utilities::Dates.nomenclature_date(self.day, self.month, self.year)
  end

  #todo move the test for nomenclature_date to spec/lib/utilities/dates_spec.rb

  #endregion    time/date related

  #region cached values section
  #

  # @return [String]
  #   a full representation, using bibtex
  # String must be length > 0
  def cached_string(format)
    unless (format == 'text') || (format == 'html')
      return(nil)
    end

    bx_entry = self.to_bibtex

    if bx_entry.key.blank?
      bx_entry.key = 'tmpID'
    end

    if bx_entry.year.blank? # cludge to fix render problem with year
      bx_entry.year = '0000'
    end

    key             = bx_entry.key
    bx_bibliography = BibTeX::Bibliography.new
    bx_bibliography.add(bx_entry)

    cp = CiteProc::Processor.new(style: 'zootaxa', format: format)
    cp.import(bx_bibliography.to_citeproc)
    output = cp.render(:bibliography, id: key).first.strip

    output.sub('(0ADAD)', '') # citeproc renders year 0000 as (0ADAD)
  end

  #endregion cached values section

  protected

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
  def set_cached
    if self.errors.empty?
      tmp                       = cached_string('text')
      self.cached               = tmp
      self.cached_author_string = authority_name

      if self.authors.size > 0
        self.author = self.compute_bibtex_names('author')
      end

      if self.editors.size > 0
        self.editor = self.compute_bibtex_names('editor')
      end
    end
  end

  #region hard validations

  # must have at least one of the required fields (TW_REQUIRED_FIELDS)
  def check_has_field
    valid = false
    TW_REQUIRED_FIELDS.each do |i|
      if !self[i].blank?
        valid = true
        break
      end
    end
    errors.add(:base, 'There is no core data provided.') if !valid
  end

  #endregion  hard validations

  #region Soft_validation_methods
  def sv_has_authors
    if !(has_authors?)
      soft_validations.add(:author, 'There is no author associated with this source.')
    end
  end

  def sv_contains_a_writer # neither author nor editor
    if !has_writer?
      soft_validations.add(:base, 'There is neither author, nor editor associated with this source.')
    end
  end

  def sv_has_title
    if self.title.blank?
      soft_validations.add(:title, 'There is no title associated with this source.')
    end
  end

  def sv_has_some_type_of_year
    if !has_some_year?
      soft_validations.add(:base, 'There is no year nor is there a stated year associated with this source.')
    end
  end

  def sv_year_exists
    if year.blank?
      soft_validations.add(:year, 'There is no year associated with this source.')
    elsif year < 1700
      soft_validations.add(:year, 'This year is prior to the 1700s')
    end
  end

  # def sv_missing_journal
  # never used
  #   soft_validations.add(:bibtex_type, 'The source is missing a journal name.') if self.journal.blank?
  # end

  def sv_is_article_missing_journal
    if self.bibtex_type == 'article'
      if self.journal.blank? and self.serial.blank?
        soft_validations.add(:bibtex_type, 'This article is missing a journal name or serial.')
      end
    end
  end

  def sv_has_a_publisher
    if self.publisher.blank?
      soft_validations.add(:publisher, 'Valid BibTeX requires a publisher to be associated with this source.')
    end
  end

  def sv_has_booktitle
    if self.booktitle.blank?
      soft_validations.add(:booktitle, 'Valid BibTeX requires a book title to be associated with this source.')
    end
  end

  def sv_is_contained_has_chapter_or_pages
    if self.chapter.blank? && self.pages.blank?
      soft_validations.add(:bibtex_type, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')

      #  soft_validations.add(:chapter, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')
      # soft_validations.add(:pages, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')
    end
  end

  def sv_has_school
      if self.school.blank?
        soft_validations.add(:school, 'Valid BibTeX requires a school associated with any thesis.')
      end
  end

  def sv_has_institution
      if self.institution.blank?
        soft_validations.add(:institution, 'Valid BibTeX requires an institution with a tech report.')
      end
  end

  def sv_has_note
    if (self.note.blank?) && (self.notes.count = 0)
      soft_validations.add(:note, 'Valid BibTeX requires a note with an unpublished source.')
    end
  end

  def sv_missing_required_bibtex_fields
    case self.bibtex_type
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

  #endregion   Soft_validation_methods

end

