# Methods to resolve a group of columns and their values to
# an instance in TW, columns should be a Hash of legal
# values at this point
#
module BatchLoad::ColumnResolver

  class << self

    # @param [Hash] columns
    # @param [String] type of DataAttribute
    # @return [BatchLoad::ColumnResolver::Result]
    def data_attribute(columns, type = 'import')
      r = BatchLoad::ColumnResolver::Result.new

      predicate = columns['predicate']
      value = columns['value']
      proj_id = columns['project_id']
      r.error_messages << 'No column for \'Value\' was provided.' unless columns.key?('value')
      r.error_messages << 'No column for \'Predicate\' was provided.' unless columns.key?('predicate')
      r.error_messages << 'No content for \'Value\' was provided.' if value.blank?
      r.error_messages << 'No content for \'Predicate\' was provided.' if predicate.blank?

      if type.start_with?('im')
        r.assign(DataAttribute.where(import_predicate: predicate, value: value, project_id: proj_id).to_a)
      else
        cvt = ControlledVocabularyTerm.find_by(name: predicate, project_id: proj_id)
        r.assign(DataAttribute.where(controlled_vocabulary_term_id: cvt&.id, value: value, project_id: proj_id).to_a)
      end
      r.error_messages << "Multiple data_attributes match for '#{predicate}' and '#{value}'.'" if r.multiple_matches?

      r
    end

    # rubocop:disable Metrics/MethodLength
    # @param [Hash] columns
    # @return [BatchLoad::ColumnResolver::Result]
    def otu(columns)
      r = BatchLoad::ColumnResolver::Result.new

      if columns['otu_id']
        begin
          r.assign Otu.find(columns['otu_id'])
        rescue => _e # ActiveRecord::RecordNotFound
          r.error_messages << "No OTU with id #{columns['otu_id']} exists."
        end
      elsif columns['otu_name']
        r.assign Otu.where(name: columns['otu_name'], project_id: columns['project_id']).limit(10).to_a
        r.error_messages << "Multiple OTUs matched the name '#{columns['otu_name']}'." if r.multiple_matches?
        r.error_messages << "No OTU with name '#{columns['otu_name']}' exists." if r.no_matches?
      elsif columns['taxon_name']
        r.assign Otu.joins(:taxon_names).where(taxon_names: {cached: columns['taxon_name']}, project_id: columns['project_id']).limit(10).to_a
        r.error_messages << "Multiple OTUs matched the taxon name '#{columns['taxon_name']}'." if r.multiple_matches?
      elsif columns.key?('otuname')
        name = columns['otuname']
        proj_id = columns['project_id']
        list = Otu.where(name: name, project_id: proj_id).limit(2)
        if list.blank? # treat it like a taxon name
          list = Otu.joins(:taxon_name)
                     .where(taxon_names: {cached: name}, project_id: proj_id)
                     .limit(2)
        end
        r.assign(list.to_a)
        r.error_messages << "Multiple OTUs matched the name '#{name}'." if r.multiple_matches?
        r.error_messages << "No OTU with name '#{name}' exists." if r.no_matches?
      else
        r.error_messages << 'No column suitable for OTU resolution was provided.'
      end

      r
    end

    # rubocop:enable Metrics/MethodLength

    # @param [Hash] columns
    # @return [BatchLoad::ColumnResolver::Result]
    def collection_object_by_identifier(columns)
      r = BatchLoad::ColumnResolver::Result.new

      # find a namespace (ns1) with a short_name of row[headers[0]] (id1)
      # find a collection_object which has an identifier which has a namespace (ns1), and a cached of
      # (ns1.short_name + ' ' + identifier.identifier)
      # ns1    = Namespace.where(short_name: id1).first

      ident_text = columns['catalog_number']
      ident_text = columns['collection_object_identifier'] if ident_text.blank?

      ident_text = "#{columns['collection_object_identifier_namespace_short_name']}" + ' ' +
          " #{columns['collection_object_identifier_identifier']}".strip if ident_text.blank?

      if ident_text.blank?
        r.error_messages << 'No column combination suitable for collection object resolution was provided.'
      else
        r.assign CollectionObject.joins(:identifiers).where(identifiers: {cached: ident_text}).to_a
        r.error_messages << "No collection object with cached identifier '#{ident_text}' exists." if r.no_matches?
      end
      r
    end

    # @param [Hash] columns
    # @return [BatchLoad::ColumnResolver::Result]
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

    # rubocop:disable Metrics/MethodLength
    # @param [Hash] columns
    # @param [String] data_origin
    # @return [BatchLoad::ColumnResolver::Result]
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
        r.error_messages << "Multiple matches to '#{search_list}' (data_origin: #{data_origin}) were found." if r.multiple_matches?

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
    # rubocop:enable Metrics/MethodLength
  end
end
