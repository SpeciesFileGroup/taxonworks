module Tasks::Gis::ReportHelper

  ALLHEADERS = ['Collecting Event', 'Collection Object', 'Bio classification']

  def helper_download_button
    submit_tag('download', {disabled: params[:geographic_area_id].nil?}) +
      hidden_field_tag(:download_geo_area_id, params[:geographic_area_id])
  end

  def tag_headers
    retval = ''
    ALLHEADERS.each { |header|
      retval += "<th>#{header}</th>"
    }
    retval
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
    # Predicate.includes(:internal_attributes).where(data_attributes: {attribute_subject_type: 'CollectionObject'}, project_id: 1).uniq.map(&:name)
    # BiocurationClass.all.map(&:name)
  end

  def c_o_attributes(attribute_list = [])
    retval = ''
    attribute_list.each { |attribute|
      retval += "<td>#{attribute}</td>"
    }
    retval
  end

  def ce_headers

    # retval = []
    # retval = CollectionObject.ce_headers(@collection_objects) if @with_ce
    # retval
    retval               = {}
    retval[:ce_internal] = InternalAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectingEvent').map(&:predicate).map(&:name).uniq.sort
    retval[:ce_import]   = ImportAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectingEvent').pluck(:import_predicate).uniq.sort
    retval
  end

  def ce_attributes(collection_object)
    retval = []
    if @with_ce
      ce_headers.each { |header|
        retval.push(collection_object.collecting_event.data_attributes.select { |d| d.predicate.name == header }.map(&:value).join('; '))
      }
    end
    retval
  end

  def co_headers
    # retval = []
    # retval = CollectionObject.co_headers(@collection_objects) if @with_co
    # retval
    retval               = {}
    retval[:co_internal] = InternalAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectionObject').map(&:predicate).map(&:name).uniq.sort
    retval[:co_import]   = ImportAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectionObject').pluck(:import_predicate).uniq.sort
    retval
  end

  def co_attributes(collection_object)
    retval = []
    if @with_co
      co_headers.each { |header|
        retval.push(collection_object.data_attributes.select { |d| d.predicate.name == header }.map(&:value).join('; '))
      }
    end
    retval
  end

  def bc_headers
    # retval = []
    # retval = CollectionObject.bc_headers(@collection_objects) if @with_bc
    # retval
    retval      = {}
    retval[:bc] = BiocurationClass.all.map(&:name)
    retval
  end

  def bc_attributes(collection_object)
    retval = []
    if @with_bc
      bc_headers.each { |header|
        retval.push(collection_object.biocuration_classes.map(&:name).include?(header) ? '1' : '0')
      }
    end
    retval
  end

  def combine_sub_headers(headers)
    retval = []
    keys   = headers.keys
    keys.each { |key|
      case key
        when /_imp/
          headers[key].each { |item|
            retval.push('* ' + item)
          }
        else
          headers[key].each { |item|
            retval.push(item)
          }
      end
    }
    retval
  end

  def all_sub_headers
    sub_headers = []
    sub_headers.push(combine_sub_headers(ce_headers))
    sub_headers.push(combine_sub_headers(co_headers))
    sub_headers.push(combine_sub_headers(bc_headers))
    index = 0; retstring = ''
    until sub_headers[0][index].nil? && sub_headers[1][index].nil? && sub_headers[2][index].nil?
      retstring += "<tr>"
      ALLHEADERS.each_with_index { |header, inner|
        item      = sub_headers[inner][index].to_s
        retstring += "<td>#{check_box(item, false)} #{item}</td>"
      }
      retstring += "</tr>"
      index     += 1
    end

    retstring
  end

  def georeferences
    retval = @collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    retval.push(@geographic_area)
  end

end
