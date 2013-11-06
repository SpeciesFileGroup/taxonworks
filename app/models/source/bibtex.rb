# self.author & self.authors should match or one of them should be empty

class Source::Bibtex < Source

  before_validation :check_bibtex_type, :check_has_field
  #TODO: :update_authors_editor_if_changed? if: Proc.new { |a| a.password.blank? }

  has_many :author_roles, class_name: 'Role::SourceAuthor', as: :role_object
  has_many :authors, -> { order('roles.position ASC') }, through: :author_roles, source: :person
  has_many :editor_roles, class_name: 'Role::SourceEditor', as: :role_object
  has_many :editors, -> { order('roles.position ASC') }, through: :editor_roles, source: :person

  #region soft_validate calls
  soft_validate(:sv_authors_exist)
  soft_validate(:sv_year_exists)
  soft_validate(:sv_date_exists, set: :recommended_fields)
  #soft_validate(:no_writer, set: :recommended_fields)
  #soft_validate(:no_title, set: :recommended_fields)
  #soft_validate(:sv_journal_exists, set: :recommended_fields)
  #soft_validate(:sv_URL_exists, set: :recommended_fields)
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
  ]
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

  def has_authors?
    # return true if there is a bibtex author or if author roles exist.

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

  def has_date? # is there a year or stated year?
    return true if !(self.year.blank?)
    return true if !(self.stated_year.blank?)
    return false
  end

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
  def sv_authors_exist
    if !(has_authors?)
      soft_validations.add(:author, 'There is no author associated with this source')
    end
  end

  def no_writer # neither author nor editor
    if !(has_authors?) && !(has_editors?)
      soft_validations.add(:author, 'There is neither an author,nor editor associated with this source')
      soft_validations.add(:editor, 'There is neither an author,nor editor associated with this source')
    end
  end

  def no_title
    if (self.title.blank?)
      soft_validations.add(:title, 'There is no title associated with this source')
    end
  end

  def sv_date_exists
    if (has_date?)
      soft_validations.add(:year, 'There is no year or stated year associated with this source')
      soft_validations.add(:stated_year, 'There is no or stated year year associated with this source')
    end
  end

  def sv_year_exists
    if !(year.blank?)
      soft_validations.add(:year, 'There is no year associated with this source.')
    end
  end

  def no_journal
    soft_validations.add(:bibtex_type, 'The source is missing a journal name') if self.journal.blank?
  end

  def article_missing_journal
    if (self.bibtex_type == 'article')
      if (self.journal.blank?)
        soft_validations.add(:bibtex_type, 'The article is missing a journal name')
      end
    end
  end

  def no_publisher
    if (self.publisher.blank?)
      soft_validations.add(:publisher, 'There is no publisher associated with this source')
    end
  end

  def no_booktitle
    if (self.booktitle.blank?)
      soft_validations.add(:booktitle, 'There is no book title associated with this source')
    end
  end

  def no_included
    if self.chapter.blank? && self.pages.blank?
      soft_validations.add(:chapter, 'There is neither a chapter nor pages with this source')
      soft_validations.add(:pages, 'There is neither a chapter nor pages with this source')
    end
  end

  def missing_required_bibtex_fields
    case self.bibtex_type
      when 'article' #:article       => [:author,:title,:journal,:year]
        sv_authors_exist
        no_title
        article_missing_journal
        sv_year_exists
      when 'book' #:book          => [[:author,:editor],:title,:publisher,:year]
        self.no_writer
        self.no_title
        self.no_publisher
        sv_year_exists
      when 'booklet' #    :booklet       => [:title],
        self.no_title
      when 'conference' #    :conference    => [:author,:title,:booktitle,:year],
        sv_authors_exist
        self.no_title
        self.no_booktitle
        sv_year_exists
      when 'inbook' #    :inbook        => [[:author,:editor],:title,[:chapter,:pages],:publisher,:year],
        self.no_writer
        self.no_title
        self.no_included
        self.no_publisher
        sv_year_exists
      when 'incollection' #    :incollection  => [:author,:title,:booktitle,:publisher,:year],
        sv_authors_exist
        self.no_title
        self.no_booktitle
        self.no_publisher
        sv_year_exists
      when 'inproceedings' #    :inproceedings => [:author,:title,:booktitle,:year],
        sv_author_exists
        no_title
        no_booktitle
        sv_year_exists
      when 'manual' #    :manual        => [:title],
        self.no_title
      when 'mastersthesis' #    :mastersthesis => [:author,:title,:school,:year],
        sv_authors_exist
        self.no_title
      #    :misc          => [],
      when 'phdthesis' #    :phdthesis     => [:author,:title,:school,:year],
      when 'proceedings' #    :proceedings   => [:title,:year],
      when 'techreport' #    :techreport    => [:author,:title,:institution,:year],
      when 'unpublished' #    :unpublished   => [:author,:title,:note]
        sv_author_exists
        no_title
        #check for note

    end

  end

  #endregion
end

