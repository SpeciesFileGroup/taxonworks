module GeneAttributesHelper
  def gene_attribute_tag(gene_attribute)
    return nil if gene_attribute.nil?
    gene_attribute.id
  end

  def gene_attributes_search_form
    render('/gene_attributes/quick_search_form')
  end

  def gene_attribute_link(gene_attribute)
    return nil if gene_attribute.nil?
    link_to(gene_attribute_tag(gene_attribute).html_safe, gene_attribute)
  end
end
