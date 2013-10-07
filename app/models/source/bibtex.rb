class Source::Bibtex < Source 

  # have some authors and editors

  has_many :authors, -> {where role: {type: 'SourceAuthor'} }, through: :roles, source: :person
  has_many :editors, -> {where role: {type: 'SourceEditor'} }, through: :roles, source: :person

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

end

