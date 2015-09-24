module Tasks::Gis::ReportHelper

  # decode which headers to be displayed for collecting events
  def ce_attrib_headers
    @ce_headers = @collection_objects.map(&:collecting_event).map(&:data_attributes).flatten.map(&:predicate).map(&:name).uniq.sort
    retval      = ''
    @ce_headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  def ce_attributes(collection_object)
    retval = ''
    @ce_headers.each { |header|
      retval += "<td>#{collection_object.collecting_event.data_attributes.select { |d| d.predicate.name == header }.map(&:value).join('; ')}</td>"
    }
    retval
  end

# decode which headers to be displayed for collection objects
  def co_attrib_headers
    @co_headers = @collection_objects.map(&:data_attributes).flatten.map(&:predicate).map(&:name).uniq.sort
    retval      = ''
    @co_headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  def co_attributes(collection_object)
    retval = ''
    @co_headers.each { |header|
      retval += "<td>#{collection_object.data_attributes.select { |d| d.predicate.name == header }.map(&:value).join('; ')}</td>"
    }
    retval
  end

# decode which headers to be displayed for biocurational classifications
  def bc_headers
    @bc_headers = @collection_objects.map(&:biocuration_classifications).flatten.map(&:biocuration_class).map(&:name).uniq.sort
    retval      = ''
    @bc_headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  def bc_attributes(collection_object)
    retval = ''
    @bc_headers.each { |header|
      retval += "<td>#{header}</td>"
    }
    retval
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
    collection_object.otus.first unless collection_object.otus.empty?
  end

  def get_otu_id(otu)
    otu.id unless otu.nil?
  end

  def get_otu_name(otu)
    otu.name unless otu.nil?
  end

  def get_otu_taxon_name(otu)
    otu.taxon_name unless otu.nil?
  end

  def check_nil(object)

  end

  def name_at_rank_string(collection_object, rank)
    # retval = ''
    object = get_otu_taxon_name(get_otu(collection_object))
    retval = object.ancestor_at_rank(rank) unless object.nil?
    retval.nil? ? '' : retval.cached_html.html_safe
  end

end
