module TaxonNamesHelper
  def big_purple_word(purple)
    content_tag(:span, purple, {style: 'color:purple; font-size:50px'})
  end
end
