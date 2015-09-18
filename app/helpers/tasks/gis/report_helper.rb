module Tasks::Gis::ReportHelper

  # decode which headers to be displayed for collecting events
  def ce_attrib_headers
    "<th>CE headers</th>"
  end

  # decode which headers to be displayed for collection objects
  def co_attrib_headers
    "<th>CO headers</th>"
  end

  # decode which headers to be displayed for biocurational classifications
  def bc_headers
    "<th>BC headers</th>"
  end

  def otu_headers

  end

  def get_otu(collection_object)
    collection_object.otus.first
  end

  def check_nil(object)

  end

  def name_at_rank_string(collection_object, rank)
    retval = ''
    object = get_otu(collection_object).taxon_name
    retval = object.ancestor_at_rank(rank) unless object.nil?
    retval.nil? ? '' : retval.cached_html.html_safe
  end

end
