module Tasks::Gis::ReportHelper

  ALLHEADERS = ['Collecting Event', 'Collection Object', 'Bio classification'].freeze

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
    CollectionObject::CO_OTU_HEADERS.each { |header|
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
      group.each_key { |type|
        retval.push(group[type].keys)
      } unless group.nil?
    } unless @selected_column_names.nil?
    retval ||= {ce: {in: {}, im: {}}, # make sure all columns and types are present,
                co: {in: {}, im: {}}, # even if empty
                bc: {in: {}, im: {}}}
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
      unless @selected_column_names[column_type.to_sym][:in].nil?
        items.push(@selected_column_names[column_type.to_sym][:in].keys)
      end
      # check for import predicates (may not be present on ce and co, WILL NOT be present on bc)
      unless @selected_column_names[column_type.to_sym][:im].nil?
        unless @selected_column_names[column_type.to_sym][:im].keys.empty?
          items.push('--Import') # stuff the seperator
          items.push(@selected_column_names[column_type.to_sym][:im].keys) # stuff the headers for the import
          # predicates
        end
      end
      all_columns.push(items.flatten) # flatten is required because the internal and import headers are pushed
      # as arrays
    }
    outer     = 1 # Skip the first row; these are reflected in the word list used to iterate the columns
    retstring = ''; ce_type = 'in'; co_type = 'in' # ; sub_type = 'in'
    until all_columns[0][outer].nil? && all_columns[1][outer].nil? && all_columns[2][outer].nil?
      retstring += '<tr>' # open the row
      # across the three headers
      %w(ce co bc).each_with_index { |col_type, inner|
        item = all_columns[inner][outer].to_s
        if item.start_with?('--Imp')
          item      = item[2, item.length]
          retstring += "<th>#{item}</th>"
          case col_type
            when 'ce'
              ce_type = 'im' # switch the ce list to import
            when 'co'
              co_type = 'im' # switch the co list to import
            else
              # this will never happen...
              # sub_type = 'in'
          end
        else
          case col_type
            when 'ce'
              sub_type = ce_type
            when 'co'
              sub_type = co_type
            else
              sub_type = 'in'
          end
          if item.empty?
            retstring += '<td></td>'
          else
            stage       = @selected_column_names[col_type.to_sym][sub_type.to_sym][item]
            item_id     = stage[:id]
            item_chk    = stage[:checked]
            item_string = "hd[#{col_type}[#{sub_type}[#{item}]]]"
            retstring   += "<td>#{check_box(item_string, :checked, {checked: item_chk})} #{item}</td>"
          end
        end
      }
      retstring += '</tr>' # close the row
      outer     += 1
    end

    retstring
  end

  # @return [Array] of geo_objects which may have a shape to display
  def report_georeferences(collection_objects, geographic_area)

    # all georeferences for a set of collection objects
    #  retval = collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    retval = Georeference.joins(collecting_event: [:collection_objects]).
      where(collection_objects: {id: collection_objects}).to_a

    if retval.empty? # if no georeferences, show the geographic_area
      retval.push(geographic_area)
    end
    retval
  end

  def count_info(count)
    term = 'Collection object'
    if count < 25
      if count == 0
        retval = "No #{term}s"
      else
        if count == 1
          retval = "1 #{term}"
        else
          retval = "#{count} #{term}s"
        end
      end
    else
      retval = "First 25 of #{count} Collection objects"
    end
    retval + ':'
  end

  def table_start
    @c_o_table_data  = {}
    @c_o_table_store = Redis.new

    begin
      @c_o_table_store.ping
    rescue Exception => e
      @c_o_table_store = nil
      e.inspect
      e.message
      # puts "#{e.inspect}"
      # e.inspect
    end
    @c_o_table_store

  end

  def table_complete
    unless @c_o_table_store.nil?
      table_string = sessions_current_user.email + '-c_o_table_data'
      @c_o_table_store.set(table_string, @c_o_table_data.to_json)
    end
    @c_o_table_data.count
  end

  # @param [CollectionObject] c_o
  # @return [Array] row of data
  def build_row(c_o)
    retval = []

    retval[0]  = c_o.otu_id
    retval[1]  = c_o.otu_name
    retval[2]  = c_o.name_at_rank_string(:family)
    retval[3]  = c_o.name_at_rank_string(:genus)
    retval[4]  = c_o.name_at_rank_string(:species)
    retval[5]  = c_o.dwc_country # c_o.collecting_event.country
    retval[6]  = c_o.dwc_state_province # c_o.collecting_event.state
    retval[7]  = c_o.dwc_county # c_o.collecting_event.county
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

  def report_paging_info
    # <p><%= page_entries_info(@collection_objects) %></p> <%= paginate @collection_objects %>
    if @list_collection_objects.any?
      page_entries_info(@list_collection_objects)
    end
  end

  def report_paging
    if @list_collection_objects.any?
      paginate(@list_collection_objects, remote: true)
    end
  end


end
