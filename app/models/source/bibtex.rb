# @author Elizabeth Frank <eef@illinois.edu> INHS University of IL
#
# Bibtex - Subclass of Source that represents most references.
#
# TaxonWorks(TW) relies on the bibtex-ruby gem to input or output BibTeX bibliographies,
# and has a strict list of required fields. TW itself only requires that :bibtex_type
# be valid and that one of the attributes in TW_REQ_FIELDS be defined.
# This allows a rapid input of incomplete data, but also means that not all TW Source::Bibtex
# objects can be added to a BibTeX bibliography.
#
#  The following information is taken from _BibTeXing_, by Oren Patashnik, February 8, 1988
#  http://ftp.math.purdue.edu/mirrors/ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf
#  (and snippets are cut from this document for the attribute descriptions)
#
#  BibTeX fields in a BibTex bibliography are treated in one of three ways:
#   REQUIRED - Omitting the field will produce a warning message and, rarely, a
#       badly formatted bibliography entry. If the required information is not
#       meaningful, you are using the wrong entry type. However, if the required
#       information is meaningful but, say, already included is some other field,
#       simply ignore the warning.
#   OPTIONAL - The field's information will be used if present, but can be omitted
#       without causing any formatting problems. You should include the optional
#       field if it will help the reader.
#   IGNORED - The field is ignored. BibTEX ignores any field that is not required or
#       optional, so you can include any fields you want in a bib file entry. It's a
#       good idea to put all relevant information about a reference in its bib file
#       entry - even information that may never appear in the bibliography.
#
# TW will add all non-standard or housekeeping attributes to the bibliography even though
# the data may be ignored.
#
# @!group Ruby standard attributes & our added housekeeping fields
# @!attribute id [Fixnum]
#   This is the Ruby Active Record ID. When no value is provided for the key field and
#   a cross reference is needed, this field will be used within the key.
#   @return [Fixnum] the unique identifier of this record in the Source table.
#   @return [nil] means the record does not exist in the database.
# @!attribute serial_id [Fixnum]
#   @note not yet implemented!
#   @return [Fixnum] the unique identifier of the serial record in the Serial? table.
#   @return [nil] means the record does not exist in the database.
#
# @!endgroup
#
# @!group BibTeX attributes (based on BibTeX fields)
# @!attribute address
#   BibTeX standard field (optional for types: book, inbook, incollection, inproceedings, manual, mastersthesis,
#   phdthesis, proceedings, techreport)
#   Usually the address of the publisher or other type of institution.
#   For major publishing houses, van Leunen recommends omitting the information
#   entirely. For small publishers, on the other hand, you can help the reader by giving the complete address.
#   @return [String] the address
#   @return [nil] means the field is not stored in the database.
# @!attribute annote
#   BibTeX standard field - An annotation. It is not used by the standard bibliography styles, but
#   may be used by others that produce an annotated bibliography.
#   @return [String] the annotation
#   @return [nil] means the field is not stored in the database.
# @!attribute author
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required field (TW requires a value in one of any of the required fields.)
#   The name(s) of the author(s), in the format described in the LaTeX book. Names should be formatted as
#   "Last name, FirstName MiddleName". FirstName and MiddleName can be initials. If there are multiple authors,
#   each author name should be separated by the word " and ". It should be noted that all the names before the
#   comma are treated as a single last name.
#   @return [String] the list of author names in BibTeX format
#   @return [nil] means the field is not stored in the database.
# @!attribute editor
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required field (TW requires a value in one of any of the required fields.)
#   The name(s) of the editor(s), in the format described in the LaTeX book. Names should be formatted as
#   "Last name, FirstName MiddleName". FirstName and MiddleName can be initials. If there are multiple editors,
#   each editor name should be separated by the word " and ". It should be noted that all the names before the
#   comma are treated as a single last name.
#   @return [String] the list of eitor names in BibTeX format
#   @return [nil] means the field is not stored in the database.
# @!attribute booktitle
#   BibTeX standard field (required for types: )(optional for types:)
#   A TW required field (TW requires a value in one of the required fields.)
#   Title of a book, part of which is being cited. See the LaTEX book for how to type titles.
#   For book entries, use the title field instead.
#
# @!endgroup
# @!group TW add attributes that are not part of the standard attribute list
# @!endgroup
#
#

class Source::Bibtex < Source
  include SoftValidation
#
# @!attribute chapter
# @!attribute crossref
# @!attribute edition
# @!attribute editor
# @!attribute howpublished
# @!attribute institution
# @!attribute journal
#   A TW required field (TW requires a value in one of the required fields.)
# @!attribute key
#   Used by bibtex-ruby gem method identifier
# @!attribute month
#   use 3 letter abbreviation. see bibtex-ruby.MONTHS
# @!attribute note
# @!attribute number
# @!attribute organization
# @!attribute pages
# @!attribute publisher
# @!attribute school
# @!attribute series
# @!attribute title
#   A TW required field (TW requires a value in one of the required fields.)
# @!attribute type
# @!attribute translator - not yet implemented
#   bibtex-ruby gem supports translator, it's not clear whether TW will or not.
# @!attribute volume
# @!attribute year
#   A TW required field (TW requires a value in one of the required fields.)
# @!attribute URL
#   A TW required field (TW requires a value in one of the required fields.)
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
# @!attribute stated_year
#   A TW required field (TW requires a value in one of the required fields.)
# @!attribute verbatim
# @!attribute cached
# @!attribute cached_author_year
# @!attribute created_at
# @!attribute created_by - not yet implemented
# @!attribute updated_at
# @!attribute updated_by - not yet implemented
# @!attribute bibtex_type
#
  # @!group associations
  # @!endgroup
  # @!group identifiers
  # @!endgroup


  before_validation :check_bibtex_type, :check_has_field

  #TODO add linkage to serials ==> belongs_to serial
  #TODO :update_authors_editor_if_changed? if: Proc.new { |a| a.password.blank? }
  # @associations  authors
  #   linkage to author roles
  has_many :author_roles, class_name: 'SourceAuthor', as: :role_object
  has_many :authors, -> { order('roles.position ASC') }, through: :author_roles, source: :person
  # self.author & self.authors should match or one of them should be empty
  # ditto for self.editor & self.editors
  has_many :editor_roles, class_name: 'SourceEditor', as: :role_object
  has_many :editors, -> { order('roles.position ASC') }, through: :editor_roles, source: :person

                                                       #region soft_validate calls
  soft_validate(:sv_has_authors)
  soft_validate(:sv_year_exists)
  soft_validate(:sv_has_a_date, set: :recommended_fields)
  soft_validate(:sv_contains_a_writer, set: :recommended_fields)
  soft_validate(:sv_has_title, set: :recommended_fields)
  soft_validate(:sv_has_a_date, set: :recommended_fields)
  soft_validate(:sv_is_article_missing_journal, set: :recommended_fields)
  soft_validate(:sv_has_url, set: :recommended_fields) # probably should be sv_has_identifier instead of sv_has_url
  soft_validate(:missing_required_bibtex_fields)
                                                       #endregion

                                                       #region constants
                                                       # TW required fields (must have one of these fields filled in)
  TW_REQ_FIELDS = [
      :author,
      :editor,
      :booktitle,
      :title,
      :URL,
      :journal,
      :year,
      :stated_year
  ] # either year or stated_year is acceptable
                                                       #endregion

  def to_bibtex
    b = BibTeX::Entry.new(type: self.bibtex_type)
    ::BIBTEX_FIELDS.each do |f|
      if !(f == :bibtex_type) && (!self[f].blank?)
        b[f] = self.send(f)
      end
    end
    b
  end

  def valid_bibtex?
    self.to_bibtex.valid?
  end

  def self.new_from_bibtex(bibtex_entry)
    return false if !bibtex_entry.kind_of?(::BibTeX::Entry)
    s = Source::Bibtex.new(
        bibtex_type: bibtex_entry.type.to_s,
    )
    bibtex_entry.fields.each do |key, value|
      s[key] = value.to_s
    end
    s
  end

  def create_related_people
    return false if !self.valid? ||
        self.new_record? ||
        (self.author.blank? && self.editor.blank?) ||
        self.roles.count > 0

    # if !self.valid
    #   errors.add(:base, 'invalid source')
    #   return false
    # end
    #
    # if self.new_record?
    #   errors.add(:base, 'unsaved source')
    #   return false
    # end
    #
    # if (self.author.blank? && self.editor.blank?)
    #   errors.add(:base, 'no people to create')
    #   return false
    # end
    #
    # if self.roles.count > 0
    #   errors.add(:base, 'this source already has people attached to it via roles')
    # end

    bibtex = to_bibtex
    bibtex.parse_names
    bibtex.names.each do |a|
      p = Source::Bibtex.bibtex_author_to_person(a) #p is a TW person
      if bibtex.author
        self.authors << p if bibtex.author.include?(a)
      end
      if bibtex.editor
        self.editors << p if bibtex.editor.include?(a)
      end
    end
    return true
  end

  def self.bibtex_author_to_person(bibtex_author)
    return false if bibtex_author.class != BibTeX::Name
    Person.new(
        first_name: bibtex_author.first,
        prefix:     bibtex_author.prefix,
        last_name:  bibtex_author.last,
        suffix:     bibtex_author.suffix)
  end

  #region has_<attribute>? section
  def has_authors? # is there a bibtex author or author roles?

    # return true if !(self.author.to_s.strip.length == 0)
    return true if !(self.author.blank?)
    # author attribute is empty
    return false if self.new_record?
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

  def has_date? # is there a year or stated year?
    return true if !(self.year.blank?)
    return true if !(self.stated_year.blank?)
    return false
  end

  #TODO write has_note?
  #TODO write has_identifiers?

  #endregion

  protected

  def check_bibtex_type # must have a valid bibtex_type
    errors.add(:bibtex_type, 'not a valid bibtex type') if !::VALID_BIBTEX_TYPES.include?(self.bibtex_type)
  end

  def check_has_field # must have at least one of the required fields (TW_REQ_FIELDS)
    valid = false
    TW_REQ_FIELDS.each do |i| # for each i in the required fields list
      if !self[i].blank?
        valid = true
        break
      end
    end
    # if i is not nil and not == "", it's validly_published
    #if (!self[i].nil?) && (self[i] != '')
    #  return true
    #end
    errors.add(:base, 'no core data provided') if !valid
                      # return false # none of the required fields have a value
  end

  #region Soft_validation_methods
  def sv_has_authors
    if !(has_authors?)
      soft_validations.add(:author, 'There is no author associated with this source.')
    end
  end

  def sv_contains_a_writer # neither author nor editor
    if !has_writer?
      soft_validations.add(:author, 'There is neither an author,nor editor associated with this source.')
      soft_validations.add(:editor, 'There is neither an author,nor editor associated with this source.')
    end
  end

  def sv_has_title
    if (self.title.blank?)
      soft_validations.add(:title, 'There is no title associated with this source.')
    end
  end

  def sv_has_a_date
    if (has_date?)
      soft_validations.add(:year, 'There is no year or stated year associated with this source.')
      soft_validations.add(:stated_year, 'There is no or stated year year associated with this source.')
    end
  end

  def sv_year_exists
    if !(year.blank?)
      soft_validations.add(:year, 'There is no year associated with this source.')
    end
  end

  def sv_missing_journal
    soft_validations.add(:bibtex_type, 'The source is missing a journal name.') if self.journal.blank?
  end

  def sv_is_article_missing_journal
    if (self.bibtex_type == 'article')
      if (self.journal.blank?)
        soft_validations.add(:bibtex_type, 'The article is missing a journal name.')
      end
    end
  end

  def sv_has_a_publisher
    if (self.publisher.blank?)
      soft_validations.add(:publisher, 'There is no publisher associated with this source.')
    end
  end

  def sv_has_booktitle
    if (self.booktitle.blank?)
      soft_validations.add(:booktitle, 'There is no book title associated with this source.')
    end
  end

  def sv_is_contained_has_chapter_or_pages
    if self.chapter.blank? && self.pages.blank?
      soft_validations.add(:chapter, 'There is neither a chapter nor pages with this source.')
      soft_validations.add(:pages, 'There is neither a chapter nor pages with this source.')
    end
  end

  def sv_has_school
    if (self.school.blank?)
      soft_validations.add(:school, 'There is no school associated with this thesis.')
    end
  end

  def sv_has_institution
    if (self.institution.blank?)
      soft_validations.add(:institution, 'There is not institution associated with this  tech report.')
    end
  end

  def sv_has_identifier
    #  TODO write linkage to identifiers (rather than local field save)
    # we have URL, ISBN, ISSN & LCCN as bibtex fields, but they are also identifiers.
    # do need to make the linkages to identifiers as well as save in the local field?
  end

  def sv_has_url
    if (self.URL.blank?)
      soft_validations.add(:URL, 'There is no URL associated with this source.')
    end
  end

  def sv_has_note
    # TODO we may need to check of a note in the TW sense as well - has_note? above.
    if (self.note.blank?)
      soft_validations.add(:note, 'There is no note associated with this source.')
    end

  end

  def missing_required_bibtex_fields
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

  #endregion

end

