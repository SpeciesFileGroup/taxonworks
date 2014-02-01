
class DynamicContent

  DYNAMIC_CONTENT_CLASSES = self.descendants

  attr_accessible :otu

  def initialize(options = {})
    opts = {
      otu: nil,
      keywords: nil
    }.merge!(options)

    @otu = opts[:otu]
    return false if opts[:otu].nil? || !opts[:otu]
  end 


  # !! All view related properties should be defined in a helper/view
  # !! e.g. we shouldn't need a render_header? instance method here

  def section_header
    "Unamed section for "#{self.class.name}."
  end

  def public_header
    'No header defined for this section type.  Contact your developer.'
  end


  def data
    []    
  end

  def keyword_scopable?
    false
  end 

end


