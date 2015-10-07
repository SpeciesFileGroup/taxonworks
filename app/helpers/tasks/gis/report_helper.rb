module Tasks::Gis::ReportHelper

  def helper_download_button
    submit_tag('download', {disabled: params[:geographic_area_id].nil?})
  end

  def all_headers
    retval = []
    file   = '' #   = Tasks::Gis::ReportController.report_file
    unless file.empty?
      row = file.split("\n")[0]
      unless row.empty?
        row.split(',').each { |header|
          retval += "<th>#{header}</th>\n"
        }
      end
    end
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

  def ce_headers
    retval = []
    retval = CollectionObject.ce_headers(@collection_objects) if @with_ce
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
    retval = []
    retval = CollectionObject.co_headers(@collection_objects) if @with_co
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
    retval = []
    retval = CollectionObject.bc_headers(@collection_objects) if @with_bc
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

  def georeferences
    retval = @collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    retval.push(@geographic_area)
  end
end
