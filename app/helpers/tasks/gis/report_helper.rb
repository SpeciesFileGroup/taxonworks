module Tasks::Gis::ReportHelper

  def helper_download_link
    if params[:geographic_area_id].nil?
      '(download unavailable)'
    else
      link_to('download', gis_report_download_path(params[:geographic_area_id]))
    end
  end

  def otu_headers
    retval = ''
    CO_OTU_Headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  def c_o_headers(header_list = [])
    retval = ''
    header_list.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  def c_o_attributes(attribute_list = [])
    retval = ''
    attribute_list.each { |attribute|
      retval += "<td>#{attribute}</td>"
    }
    retval
  end

  def ce_headers
    CollectionObject.ce_headers(@collection_objects)
  end

  def ce_attributes(collection_object)
    retval = []
    ce_headers.each { |header|
      retval.push(collection_object.collecting_event.data_attributes.select { |d| d.predicate.name == header }.map(&:value).join('; '))
    }
    retval
  end

  def co_headers
    CollectionObject.co_headers(@collection_objects)
  end

  def co_attributes(collection_object)
    retval = []
    co_headers.each { |header|
      retval.push(collection_object.data_attributes.select { |d| d.predicate.name == header }.map(&:value).join('; '))
    }
    retval
  end

  def bc_headers
    CollectionObject.bc_headers(@collection_objects)
  end

  def bc_attributes(collection_object)
    retval = []
    bc_headers.each { |header|
      retval.push(collection_object.biocuration_classes.map(&:name).include?(header) ? '1' : '0')
    }
    retval
  end

  def georeferences
    retval = @collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    retval.push(@geographic_area)
  end
end
