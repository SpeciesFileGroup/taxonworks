class Source::Bibtex < Source 

  before_validation :check_bibtex_type, :check_has_field

  # have some authors and editors
  has_many :author_roles, class_name: 'Role::SourceAuthor', as: :role_object
  # eef - The following is trying to order the author list based on the order in SourceAuthor.
  has_many :authors, -> {order("roles.position ASC")}, through: :author_roles, source: :person #TODO: It works, but :order depends on table name. Check if something can be done about this.
  #has_many :authors, through: :author_roles, source: :person
  has_many :editor_roles, class_name: 'Role::SourceEditor', as: :role_object
  has_many :editors, through: :editor_roles, source: :person
  #  accepts_nested_attributes_for :authors, :author_roles, :editors, :editor_roles

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
    BIBTEX_FIELDS.each do |f|
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

    bibtex = to_bibtex
    bibtex.parse_names
    bibtex.names.each do |a|
      p = Source::Bibtex.bibtex_author_to_person(a)
      self.authors << p
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

  def self.create_with_people(all_new_people)
    # parse the authors out of the author fields, and create the role linkages if the authors exist.
    return false if !self.valid?
    # if all_new_people
  end

  protected

  def check_bibtex_type # must have a validly_published bibtex_type
   errors.add(:bibtex_type, 'not a validly_published bibtex type') if !VALID_BIBTEX_TYPES.include?(self.bibtex_type)
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

