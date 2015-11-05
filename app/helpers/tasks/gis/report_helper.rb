module Tasks::Gis::ReportHelper

  ALLHEADERS = ['Collecting Event', 'Collection Object', 'Bio classification']

  # @return [String] for download button and hidden field for geographic area id
  def helper_download_button
    submit_tag('download', {disabled: params[:geographic_area_id].nil?}) +
      hidden_field_tag(:download_geo_area_id, params[:geographic_area_id])
  end

  # @return [String] strings for predicate selection table
  def tag_headers
    retval = ''
    ALLHEADERS.each { |header|
      retval += "<th>#{header}</th>"
    }
    retval
  end

  # @return [String] common headers otu through longitude
  def otu_headers
    retval = ''
    CO_OTU_Headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  # @param [Hash] header_list construct
  # @return [String] collection of all of the headers selected
  def c_o_headers(header_list = [])
    retval = ''
    header_list.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
  end

  # @param [Array] attribute_list
  # @return [String] collection of all of the attributes selected
  def c_o_attributes(attribute_list = [])
    retval = ''
    attribute_list.each { |attribute|
      retval += "<td>#{attribute}</td>"
    }
    retval
  end

  # @return [Array] of the selected headers
  def selected_headers
    retval = []
    %w(ce co bc).each { |column|
      group = @selected_column_names[column.to_sym]
      group.keys.each { |type|
        retval.push(group[type].keys)
      }
    }
    retval.flatten
  end

  # @return [Hash] with collecting event data attribute names, both internal and import
  # can't use data_attribute.predicate_name here; it will lose the sense of source (internal or import)
  #
  def ce_headers
    @selected_column_names = CollectionObject.ce_headers(sessions_current_project_id)
  end

  # @param [CollectionObject] from which to extract attributes
  # @return [Array] of attributes
  def ce_attributes(collection_object)
    CollectionObject.ce_attributes(collection_object, @selected_column_names)
  end

  # @return [Hash] with collection object data attribute names, both internal and import
  # can't use data_attribute.predicate_name here; it will lose the sense of source (internal or import)
  #
  def co_headers
    @selected_column_names = CollectionObject.co_headers(sessions_current_project_id)
  end

  # @param [CollectionObject] from which to extract attributes
  # @return [Array] of attributes
  def co_attributes(collection_object)
    CollectionObject.co_attributes(collection_object, @selected_column_names)
  end

  # @return [Hash] with collection object data attribute names, both internal and import
  # can't use data_attribute.predicate_name here; it will lose the sense of source (internal or import)
  #
  def bc_headers
    @selected_column_names = CollectionObject.bc_headers(sessions_current_project_id)
  end

  # @param [CollectionObject] from which to extract attributes
  # @return [Array] of attributes
  def bc_attributes(collection_object)
    CollectionObject.bc_attributes(collection_object, @selected_column_names)
  end

  # @param [Boolean] filtered to indicate whether the existing hash of @selected_column_names are pre- (false) or
  # post- (true) selection
  # @return [String] of headers to be applied to table
  def all_sub_headers(filtered = false)
    unless filtered
      ce_headers # generate the header structure (see CollectionObject.selected_column_names)
      co_headers
      bc_headers
    end
    all_columns = []
    %w(ce co bc).each { |column_type|
      # stuff the column_type, just to make it easier to visualize the data organization in the debugger
      items = [column_type]
      # stuff the headers for the internal predicates
      unless @selected_column_names[column_type.to_sym][:internal].nil?
        items.push(@selected_column_names[column_type.to_sym][:internal].keys)
      end
      # check for import predicates (may not be present on ce and co, WILL NOT be present on bc)
      unless @selected_column_names[column_type.to_sym][:import].nil?
        unless @selected_column_names[column_type.to_sym][:import].keys.empty?
          items.push('--Import') # stuff the seperator
          items.push(@selected_column_names[column_type.to_sym][:import].keys) # stuff the headers for the import
          # predicates
        end
      end
      all_columns.push(items.flatten) # flatten is required because the internal and import headers are pushed
      # as arrays
    }
    index     = 1 # Skip the first row; these are reflected in the word list used to iterate the columns
    retstring = ''; ce_type = 'internal'; co_type = 'internal'; sub_type = 'internal'
    until all_columns[0][index].nil? && all_columns[1][index].nil? && all_columns[2][index].nil?
      retstring += "<tr>" # open the row
      # across the three headers
      %w(ce co bc).each_with_index { |col_type, inner|
        item = all_columns[inner][index].to_s
        if item.start_with?('--Imp')
          item      = item[2, item.length]
          retstring += "<th>#{item}</th>"
          case col_type
            when 'ce'
              ce_type = 'import' # switch the ce list to import
            when 'co'
              co_type = 'import' # switch the co list to import
            else
              # sub_type = 'internal'
          end
        else
          case col_type
            when 'ce'
              sub_type = ce_type
            when 'co'
              sub_type = co_type
            else
              sub_type = 'internal'
          end

          item_string = "headers[#{col_type}[#{sub_type}[#{item}]]]"
          retstring   += item.empty? ? "<td></td>" : "<td>#{check_box(item_string, :checked, {checked: filtered})} #{item}</td>"
        end
      }
      retstring += "</tr>" # close the row
      index     += 1
    end

    retstring
  end

  def shown_georeferences
    retval = @collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    retval.push(@geographic_area)
  end

  def table_start
    @c_o_table_data = {}
    # @c_o_table_store = Redis.new
    #
    # begin
    #   @c_o_table_store.ping
    # rescue Exception => e
    #   @c_o_table_store = nil
    #   e.inspect
    #   e.message
    #   puts "#{e.inspect}"
    #   e.inspect
    # end
    # @c_o_table_store = Redis.new

  end

  def table_complete
    # unless @c_o_table_store.nil?
    #   table_string = @sessions_current_user.email + '-c_o_table_data'
    #   @c_o_table_store.set(table_string, @c_o_table_data.to_json)
    # end
    @c_o_table_data.count
  end

  # @param [CollectionObject] c_o
  # @return [Array] row of data
  def build_row(c_o)
    retval = []

    retval[0]  = c_o.get_otu_id
    retval[1]  = c_o.get_otu_name
    retval[2]  = c_o.name_at_rank_string(:family)
    retval[3]  = c_o.name_at_rank_string(:genus)
    retval[4]  = c_o.name_at_rank_string(:species)
    retval[5]  = c_o.collecting_event.country
    retval[6]  = c_o.collecting_event.state
    retval[7]  = c_o.collecting_event.county
    retval[8]  = c_o.collecting_event.verbatim_locality
    retval[9]  = c_o.collecting_event.georeference_latitude
    retval[10] = c_o.collecting_event.georeference_longitude

    ce_attributes(c_o).each { |item|
      retval.push(item)
    }
    co_attributes(c_o).each { |item|
      retval.push(item)
    }
    bc_attributes(c_o).each { |item|
      retval.push(item)
    }
    retval.flatten!
    @c_o_table_data[c_o.id.to_s] = retval
    retval
  end

end
