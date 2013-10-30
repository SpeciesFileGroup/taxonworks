class Source::Bibtex < Source 

  before_validation :check_bibtex_type, :check_has_field

  # have some authors and editors
  has_many :author_roles, class_name: 'Role::SourceAuthor', as: :role_object
  # eef - The following is trying to order the author list based on the order in SourceAuthor.
  has_many :authors, -> {order("roles.position ASC")}, through: :author_roles, source: :person #TODO: It works, but :order depends on table name. Check if something can be done about this.

  #has_many :authors, through: :author_roles, source: :person
  has_many :editor_roles, class_name: 'Role::SourceEditor', as: :role_object
  has_many :editors, -> {order("roles.position ASC")}, through: :editor_roles, source: :person
  #  accepts_nested_attributes_for :authors, :author_roles, :editors, :editor_roles

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
    bibtex_entry.fields.each do |key,value|
      s[key] = value.to_s
    end
    s
  end

  def create_related_people
    return false if !self.valid? || 
      self.new_record?  ||
      (self.author.blank? && self.editor.blank?) ||
      self.roles.count > 0 

   #if !self.valid
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
#      q=1
    end
    return true 
  end

  def self.bibtex_author_to_person(bibtex_author)
    return false if bibtex_author.class != BibTeX::Name
    Person.new(
      first_name: bibtex_author.first, 
      prefix: bibtex_author.prefix,
      last_name: bibtex_author.last,
      suffix: bibtex_author.suffix)
  end

  #def self.create_with_people(all_new_people)
  #  # parse the authors out of the author fields, and create the role linkages if the authors exist.
  #  return false if !self.valid?
  #  # if all_new_people
  #end

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

end

