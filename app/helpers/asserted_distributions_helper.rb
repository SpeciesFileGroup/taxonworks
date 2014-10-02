module AssertedDistributionsHelper

  def self.asserted_distribution_tag(asserted_distribution)
    # asserted_distribution.cached.blank? ? 'CACHED VALUE NOT BUILT - CONTACT ADMIN' : asserted_distribution.cached
    return nil if asserted_distribution.nil?
    asserted_distribution.verbatim_locality
  end

  def asserted_distribution_tag(asserted_distribution)
    AssertedDistributionsHelper.asserted_distribution_tag(asserted_distribution)
  end

  def asserted_distribution_link(asserted_distribution)
    return nil if asserted_distribution.nil?
    link_to(asserted_distribution_tag(asserted_distribution).html_safe, asserted_distribution)
  end

  def asserted_distributions_search_form
    render('/asserted_distributions/quick_search_form')
  end

end
