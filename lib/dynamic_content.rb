
class DynamicContent

  DYNAMIC_CONTENT_CLASSES = self.descendants

  attr_accessor :otu

  def initialize(otu: nil, keywords: nil)
    @otu = otu
    return false if otu.nil?
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


