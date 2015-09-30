module Tasks::Gis::ReportHelper

  OTU_Headers = ['OTU', 'OTU name',
                 'Family', 'Genus',
                 'Species', 'Country',
                 'State', 'County',
                 'Locality', 'Latitude', 'Longitude']

  def helper_download_link
    if params[:geographic_area_id].nil?
      '(download unavailable)'
    else
      link_to('download', gis_report_download_path(params[:geographic_area_id]))
    end
  end

  def otu_headers
    retval = ''
    OTU_Headers.each { |header|
      retval += "<th>#{header}</th>\n"
    }
    retval
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
