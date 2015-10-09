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

    retval               = {}
    retval[:ce_internal] = InternalAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectingEvent').map(&:predicate).map(&:name).uniq.sort
    retval[:ce_import]   = ImportAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectingEvent').pluck(:import_predicate).uniq.sort
    @ce_headers          = retval
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
    retval               = {}
    retval[:co_internal] = InternalAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectionObject').map(&:predicate).map(&:name).uniq.sort
    retval[:co_import]   = ImportAttribute.where(project_id: sessions_current_project_id, attribute_subject_type: 'CollectionObject').pluck(:import_predicate).uniq.sort
    @co_headers          = retval
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
    @bc_headers = retval
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
    retval += [keys[0][0, 2]]
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
    sub_headers = []; col_types = []
    item        = combine_sub_headers(ce_headers)
    col_types.push(item[0])
    sub_headers.push(item)
    item = combine_sub_headers(co_headers)
    col_types.push(item[0])
    sub_headers.push(item)
    item = combine_sub_headers(bc_headers)
    col_types.push(item[0])
    sub_headers.push(item)
    index = 1; retstring = ''
    until sub_headers[0][index].nil? && sub_headers[1][index].nil? && sub_headers[2][index].nil?
      retstring += "<tr>"
      # across the three headers
      ALLHEADERS.each_with_index { |header, inner|
        col_type  = col_types[inner] + '-'
        item      = sub_headers[inner][index].to_s
        retstring += item.empty? ? "<td></td>" : "<td>#{check_box(item, col_type + item, {checked: false})} #{item}</td>"
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
