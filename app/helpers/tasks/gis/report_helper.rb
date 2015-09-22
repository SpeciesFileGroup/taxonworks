module Tasks::Gis::ReportHelper

  # decode which headers to be displayed for collecting events
  def ce_attrib_headers
    if nil
      "<th>CE data attributes</th>"
    else
      ''
    end
  end

  # decode which headers to be displayed for collection objects
  def co_attrib_headers
    co_headers = @collection_objects.map(&:data_attributes).flatten.map(&:predicate).map(&:name).uniq.sort
    retval     = ''
    co_headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  # decode which headers to be displayed for biocurational classifications
  def bc_headers
    if nil
      "<th>BC data attributes</th>"
    else
      ''
    end
  end

  def otu_headers

  end

  def georeferences
    retval = @collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    retval.push(@geographic_area)
  end

  def parse_names(collection_object)
    @geo_names = collection_object.collecting_event.names
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
