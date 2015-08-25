# Methods to resolve a group columns and their values to 
# an instance in TW, columns should be a Hash of legal
# values at this point
# 
module BatchLoad::ColumnResolver

  class << self

    def otu(columns)
      r = BatchLoad::ColumnResolver::Result.new

      if columns['otu_id']
        begin
          r.assign Otu.find(columns['otu_id'])
        rescue => e  # ActiveRecord::RecordNotFound
          r.error_messages << "No OTU with id #{columns['otu_id']} exists."
        end
      elsif columns['otu_name']
        r.assign Otu.where(name: columns['otu_name'], project_id: columns['project_id']).limit(10).to_a
        r.error_messages << "Multiple OTUs matched the name '#{columns['otu_name']}'." if r.multiple_matches?
        r.error_messages << "No OTU with name '#{columns['otu_name']}' exists." if r.no_matches?
      elsif columns['taxon_name']
        r.assign Otu.joins(:taxon_names).where(taxon_names: {cached: columns['taxon_name']}, project_id: columns['project_id']).limit(10).to_a
        r.error_messages << "Multiple OTUs matched the taxon name '#{columns['taxon_name']}'." if r.multiple_matches?
      else
        r.error_messages << 'No column suitable for OTU resolution was provided.'
      end

      r
    end

    def source(columns)
      r = BatchLoad::ColumnResolver::Result.new

      if columns['source_id']
        begin
          r.assign Source.find(columns['source_id'])
        rescue ActiveRecord::RecordNotFound
          r.error_messages << "No source with id #{columns['source_id']} exists."
        end
      elsif columns['doi']
        r.assign Source.where(doi: columns['doi']).limit(10).to_a # identifier is cached here, so we don't have to join Identifers
        r.error_messages << "Multiple matches to the DOI '#{column['doi']}' were found." if r.multiple_matches?
      elsif columns['citation']
        r.assign Source.where(cached: columns['citation']).limit(10).to_a
        r.error_messages << "Multiple matches to the citation '#{column['citation']}' were found." if r.multiple_matches?
        r.error_messages << "No source with citation '#{columns['citation']}' exists." if r.no_matches?
      end

      r
    end

    def geographic_area(columns, data_origin = nil)
      r = BatchLoad::ColumnResolver::Result.new

      if columns['geographic_area_id']
        begin
          r.assign(GeographicArea.find(columns['geographic_area_id']))
        rescue ActiveRecord::RecordNotFound
          r.error_messages << "No Geographic area with id #{columns['source_id']} exists."
        end
      elsif columns['geographic_area_name']
        search_list = columns['geographic_area_name']
        # @tuckerjd - fix the data_origin logic
        if data_origin.blank?
          data_origin = 'blank'
          r.assign(GeographicArea.where(name: search_list).limit(10).to_a)
        else
          r.assign(GeographicArea.where(name: search_list, data_origin: data_origin).limit(10).to_a)
        end


        # @tuckerjd - tweak as necessary
        r.error_messages <<  "Multiple matches to '#{search_list}' (data_origin: #{data_origin}) were found." if r.multiple_matches?

      elsif columns['country'] || columns['state'] || columns['county']
        search_list = [columns['country'], columns['state'], columns['county']].compact.join(', ')

        # @tuckerjd - tweak as necessary to include data_origin
        if data_origin.blank?
          data_origin = 'blank'
          r.assign(GeographicArea.with_name_and_parent_names([columns['county'], columns['state'], columns['country']].compact).to_a)
        else
          r.assign(GeographicArea.where(data_origin: data_origin).with_name_and_parent_names([columns['county'], columns['state'], columns['country']].compact).to_a)
        end
        # @tuckerjd - tweak as necessary
        r.error_messages << "'#{search_list}' (data_origin: #{data_origin}): Geographic area was not determinable." if r.no_matches?
        r.error_messages << "Multiple matches to '#{search_list}' (data_origin: #{data_origin}) were found." if r.multiple_matches?
      end

      r
    end
  end


end
