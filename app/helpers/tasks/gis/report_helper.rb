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
  end

  def c_o_attributes(attribute_list = [])
    retval = ''
    attribute_list.each { |attribute|
      retval += "<td>#{attribute}</td>"
    }
    retval
  end

  def selected_headers(selected)
    retval   = []
    prefixes = session[:co_selected_headers][:prefixes]
    headers  = session[:co_selected_headers][:headers]
    types    = session[:co_selected_headers][:types]
    prefixes.each_with_index { |prefix, index|
      case prefix
        when selected
          item = headers[index]
          item = item[2, item.length] if item.start_with?('* ')
          retval.push(item)
        else
      end
    }
    retval
  end

  # @return [Hash] with collecting event data attribute names, both internal and import
  # can't use data_attribute.predicate_name here; it will lose the sense of source (internal or implort)
  #
  def ce_headers
    CollectionObject.ce_headers(sessions_current_project_id)
  end

  # @param [CollectionObject] from which to extract attributes
  # @return [Array] of attributes
  def ce_attributes(collection_object)
    CollectionObject.ce_attributes(collection_object, session[:co_selected_headers])
  end

  # @return [Hash] with collection object data attribute names, both internal and import
  # can't use data_attribute.predicate_name here; it will lose the sense of source (internal or implort)
  #
  def co_headers
    CollectionObject.co_headers(sessions_current_project_id)
  end

  # @param [CollectionObject] from which to extract attributes
  # @return [Array] of attributes
  def co_attributes(collection_object)
    CollectionObject.co_attributes(collection_object, session[:co_selected_headers])
  end

  def bc_headers
    CollectionObject.bc_headers(sessions_current_project_id)
  end

  # @param [CollectionObject] from which to extract attributes
  # @return [Array] of attributes
  def bc_attributes(collection_object)
    CollectionObject.bc_attributes(collection_object, session[:co_selected_headers])
  end

  def combine_sub_headers(headers)
    retval = []
    keys   = headers.keys
    retval += [keys[0][0, 2]]
    keys.each { |key|
      case key
        when /_imp/
          headers[key].each { |item|
            retval.push('--Import')
            retval.push(item)
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
    sub_headers = []; col_types = []; ce_type = 'int'; co_type = 'int'; this_type = 'ignore'
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
        col_type = col_types[inner] # + '-'
        item     = sub_headers[inner][index].to_s
        if item.start_with?('--Imp')
          item      = item[2, item.length]
          retstring += "<th>#{item}</th>"
          case col_type
            when col_types[0]
              ce_type = 'imp'
            when col_types[1]
              co_type = 'imp'
            else
              this_type = 'ignore'
          end
        else
          case col_type
            when col_types[0]
              this_type = ce_type
            when col_types[1]
              this_type = co_type
            else
              this_type = 'ignore'
          end
          item_string = "headers[#{col_type}[#{item}]]"
          retstring   += item.empty? ? "<td></td>" : "<td>#{check_box(item_string, this_type, {checked: false})} #{item}</td>"
        end
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
