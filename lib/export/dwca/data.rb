require 'zip'

module Export::Dwca

  # TODO: consider shelling to `paste` to concat files, see Dima's tutorial: https://globalnames.org/docs/tut-xsv-gnparser/

  # Wrapper to build DWCA zipfiles for a specific project.
  # See tasks/accesssions/report/dwc_controller.rb for use.
  #
  # With help from http://thinkingeek.com/2013/11/15/create-temporary-zip-file-send-response-rails/
  #
  # Usage:
  #  begin
  #   data = Dwca::Data.new(DwcOccurrence.where(project_id: sessions_current_project_id)
  #  ensure
  #   data.cleanup
  #  end
  #
  # Always use the ensure/data.cleanup pattern!
  #
  class Data

    attr_accessor :data

    attr_accessor :eml

    attr_accessor :meta

    attr_accessor :zipfile

    # @return [Scope]
    #  Required.  Of DwcOccurrence
    attr_accessor :core_scope

    # @return [Scope, nil]
    #   Returning BiologicalAssociation
    attr_accessor :biological_associations_extension

    # @return [Scope, nil]
    #   @return Image(?)
    attr_accessor :media_extension

    attr_accessor :total #TODO update

    attr_reader :filename

    attr_accessor :predicate_data

    # @return Hash
    # collection_object_predicate_id: [], collecting_event_predicate_id: []
    attr_accessor :data_predicate_ids

    # @return Array
    #   ordered in the order they will be placed in the file
    #   !!! Breaks if inter-mingled with asserted distributions !!!
    attr_accessor :collection_object_ids

    # @return Array
    attr_accessor :collection_object_attributes

    # @return Array
    attr_accessor :collecting_event_attributes

    attr_accessor :taxonworks_extension_data

    # @return Array<Symbol>
    attr_accessor :taxonworks_extension_methods

    # A Tempfile, core records and predicate data (and maybe more in future) joined together in one file
    attr_accessor :all_data

    # @param [Array<Symbol>] taxonworks_extensions List of methods to perform on each CO
    def initialize(core_scope: nil, extension_scopes: {}, predicate_extensions: {}, taxonworks_extensions: [])
      raise ArgumentError, 'must pass a core_scope' if core_scope.nil?

      @core_scope = core_scope

      @biological_associations_extension = extension_scopes[:biological_associations] #! String
      @media_extension = extension_scopes[:media] #  = get_scope(core_scope)

      @data_predicate_ids = { collection_object_predicate_id: [], collecting_event_predicate_id: [] }.merge(predicate_extensions)

      @taxonworks_extension_methods = taxonworks_extensions
    end

    # !params core_scope [String, ActiveRecord::Relation]
    #   String is fully formed SQL
    def core_scope
      if @core_scope.kind_of?(String)
        ::DwcOccurrence.from('(' + @core_scope + ') as dwc_occurrences').order('dwc_occurrences.id')
      elsif @core_scope.kind_of?(ActiveRecord::Relation)
        raise ArgumentError, 'core_scope: is not a DwcOccurrence relation' unless @core_scope.table.name == 'dwc_occurrences'

        @core_scope.order('dwc_occurrences.id')
      else
        raise ArgumentError, 'Scope is not a SQL string or ActiveRecord::Relation'
      end
    end

    def biological_associations_extension
      return nil unless @biological_associations_extension.present?
      if @biological_associations_extension.kind_of?(String)
        ::BiologicalAssociation.from('(' + @biological_associations_extension + ') as biological_associations')
      elsif @biological_associations_extension.kind_of?(ActiveRecord::Relation)
        @biological_associations_extension
      else
        raise ArgumentError, 'Scope is not a SQL string or ActiveRecord::Relation'
      end
    end

    def predicate_options_present?
      data_predicate_ids[:collection_object_predicate_id].present? || data_predicate_ids[:collecting_event_predicate_id].present?
    end

    def taxonworks_options_present?
      taxonworks_extension_methods.present?
    end

    def total
      @total ||= core_scope.size
    end

    # @return [CSV]
    #   the data as a CSV object
    def csv
      ::Export::CSV.generate_csv(
        core_scope.computed_columns,
        # TODO: check to see if we nee dthis
        exclude_columns: ::DwcOccurrence.excluded_columns,
        column_order: ::CollectionObject::DWC_OCCURRENCE_MAP.keys + ::CollectionObject::EXTENSION_FIELDS, # TODO: add other maps here
        trim_columns: true, # going to have to be optional
        trim_rows: false,
        header_converters: [:dwc_headers]
      )
    end

    # @return [Boolean]
    #   true if provided core_scope returns no records
    def no_records?
      total == 0
    end

    # @return [Tempfile]
    #   the csv data as a tempfile
    def data
      return @data if @data
      if no_records?
        content = "\n"
      else
        content = csv
      end

      @data = Tempfile.new('data.tsv')
      @data.write(content)
      @data.flush
      @data.rewind
      @data
    end

    def collection_object_ids
      @collection_object_ids ||= core_scope.select("(CASE dwc_occurrence_object_type WHEN 'CollectionObject' THEN dwc_occurrence_object_id ELSE null END) AS co_id").map{|a| a['co_id']}
    end

    # rubocop:disable Metrics/MethodLength

    def taxonworks_extension_data
      return @taxonworks_extension_data if @taxonworks_extension_data

      # hash of internal method name => csv header name
      methods = {}

      # hash of column_name => csv header name
      ce_fields = {}
      co_fields = {}

      # select valid methods, generate frozen name string ahead of time
      # add TW prefix to names
      taxonworks_extension_methods.each do |sym|
        csv_header_name = ('TW:Internal:' + sym.name).freeze
        if (method = ::CollectionObject::EXTENSION_COMPUTED_FIELDS[sym])
          methods[method] = csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_CE_FIELDS[sym])
          ce_fields[column_name] = csv_header_name
        elsif (column_name =::CollectionObject::EXTENSION_CO_FIELDS[sym])
          co_fields[column_name] = csv_header_name
        end
      end

      used_extensions = methods.values + ce_fields.values + co_fields.values

      # if no predicate data found, return empty file
      if used_extensions.empty?
        @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')
        return @taxonworks_extension_data
      end

      extension_data = []

      collection_objects.find_each do |object|
        methods.each_pair { |method, name| extension_data << [object.id, name, object.send(method)] }
      end

      # extract to ensure consistent order
      co_columns = co_fields.keys
      co_csv_names = co_columns.map { |sym| co_fields[sym] }
      co_column_count = co_columns.size
      # get all CO fields in one query, then split into triplets of [id, CSV column name, value]
      extension_data += collection_objects.pluck(:id, *co_columns)
        .flat_map { |id, *values| ([id] * co_column_count).zip(co_csv_names, values) }

      ce_columns = ce_fields.keys
      ce_csv_names = ce_columns.map { |sym| ce_fields[sym] }
      ce_column_count = ce_columns.size
      extension_data += collection_objects.joins(:collecting_event) # no point using left outer join, no event means all data is nil
        .pluck(:id, *ce_columns)
        .flat_map { |id, *values| ([id] * ce_column_count).zip(ce_csv_names, values) }

      # Create hash with key: co_id, value: [[extension_name, extension_value], ...]
      # prefill with empty values so we have the same number of rows as the main csv, even if some rows don't have
      # data attributes
      empty_hash = collection_object_ids.index_with { |_| []}

      data = extension_data.group_by(&:shift)

      data = empty_hash.merge(data)

      # write rows to csv
      headers = CSV::Row.new(used_extensions, used_extensions, true)

      tbl = CSV::Table.new([headers])

      # Get order of ids that matches core records so we can align with csv
      dwc_id_order = collection_object_ids.map.with_index.to_h

      data.sort_by {|k, _| dwc_id_order[k]}.each do |row|
        # remove collection object id, select "value" from hash conversion
        row = row[1]

        # Create empty row, this way we can insert columns by their headers, not by order
        csv_row = CSV::Row.new(used_extensions, [])

        # Add each [header, value] pair to the row
        row.each do |column_pair|
          unless column_pair.empty?
            csv_row[column_pair[0]] = Utilities::Strings.sanitize_for_csv(column_pair[1])
          end
        end

        tbl << csv_row
      end

      content = tbl.to_csv(col_sep: "\t", encoding: Encoding::UTF_8)

      @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')
      @taxonworks_extension_data.write(content)
      @taxonworks_extension_data.flush
      @taxonworks_extension_data.rewind
      @taxonworks_extension_data
    end

    # rubocop:enable Metrics/MethodLength

    # def asserted_distributions
    #   AssertedDistribution.joins(:dwc_occurrence).where(dwc_occurrence: core_scope)
    # end

    def collecting_events
      s = 'WITH co_scoped AS (' + collection_objects.to_sql + ') ' + ::CollectingEvent
        .joins('JOIN co_scoped as co_scoped1 on co_scoped1.collecting_event_id = collecting_events.id')
        .distinct
        .to_sql

      ::CollectingEvent.from('(' + s + ') as collecting_events') # .joins(:data_attributes)
    end

    def collection_object_attributes_query
      InternalAttribute
        .joins(:predicate)
        .where(attribute_subject: collection_objects)
    end

    def collection_object_attributes
      @collection_object_attributes ||= collection_object_attributes_query
        .select(
          'data_attributes.attribute_subject_id', # CollectionObject#id
          "CONCAT('TW:DataAttribute:CollectionObject:', controlled_vocabulary_terms.name) predicate",
          'data_attributes.value'
        ).collect{|r| [r['attribute_subject_id'], r['predicate'], r['value']] }
    end

    # @return Relation
    #   the unique attributes derived from CollectingEvents
    def collecting_event_attributes_query

      #     s = 'WITH touched_collection_objects AS (' + collection_objects.to_sql + ') ' + ::InternalAttribute
      #       .joins("JOIN collecting_events on data_attributes.attribute_subject_id = collecting_events.id AND data_attributes.attribute_subject_type = 'CollectingEvent'")
      #       .joins('JOIN touched_collection_objects as tco1 on tco1.collecting_event_id = collecting_events.id')
      #       .distinct
      #       .to_sql

      s = 'WITH touched_collecting_events AS (' + collecting_events.to_sql + ') ' + ::InternalAttribute
        .joins("JOIN touched_collecting_events as tce1 on data_attributes.attribute_subject_id = tce1.id AND data_attributes.attribute_subject_type = 'CollectingEvent'")
        .to_sql

      ::InternalAttribute.from('(' + s + ') as data_attributes')
    end

    #   @return Array
    #     1 row per CO per DA (type) on CE
    def collecting_event_attributes

      t = collecting_event_attributes_query.pluck(:id)

      return [] if t.empty?

      a = collection_objects.left_joins(collecting_event: [internal_attributes: [:predicate]] )
        .where("(data_attributes.id IN (#{t.join(',')}))") # mmmarg, how to do this with join
        .select('collection_objects.id', "CONCAT('TW:DataAttribute:CollectingEvent:', controlled_vocabulary_terms.name) predicate", 'data_attributes.value')

      # TODO: head scratch and get this to work with a join/CTE
      #  s = 'WITH target_data_attributes AS (' + collecting_event_attributes_query.to_sql + ') ' +
      #   collection_objects.left_joins(collecting_event: [internal_attributes: [:predicate]] )
      #    .joins('JOIN target_data_attributes tda on tda.id = data_attributes.id')
      #    .select('collection_objects.id co_id', "CONCAT('TW:DataAttribute:CollectingEvent:', controlled_vocabulary_terms.name) predicate", 'data_attributes.value')
      #    .to_sql
      #  b = ::CollectionObject.from('(' + s + ') as collection_objects')

      @collecting_event_attributes ||= a.collect{|r| [r['id'], r['predicate'], r['value']] }
    end

    def collection_objects
      # Use JOIN
      # CollectionObject.joins(:dwc_occurrence).where(dwc_occurrence: core_scope).order('dwc_occurrences.id')

      s = 'WITH dwc_scoped AS (' + core_scope.to_sql + ') ' + ::CollectionObject
        .joins("JOIN dwc_scoped as dwc_scoped1 on dwc_scoped1.dwc_occurrence_object_id = collection_objects.id and dwc_scoped1.dwc_occurrence_object_type = 'CollectionObject'")
        .to_sql

      ::CollectionObject.from('(' + s + ') as collection_objects')
    end

    def used_collection_object_predicates
      collection_object_attributes_query.select("CONCAT('TW:DataAttribute:CollectionObject:', controlled_vocabulary_terms.name) predicate_name")
        .distinct
        .collect{|r| r['predicate_name']}
    end

    def used_collecting_event_predicates
      collecting_event_attributes_query.joins(:predicate).select("CONCAT('TW:DataAttribute:CollectingEvent:', controlled_vocabulary_terms.name) predicate_name").distinct
        .collect{|r| r['predicate_name']}
    end

    # @return [Array]
    #   of distinct Predicate names in the format
    #      `TW:DataAttribute:<CollectingEvent|CollectionObject>:<name>`
    def used_predicates
      used_collection_object_predicates + used_collecting_event_predicates
    end

    def predicate_data
      return @predicate_data if @predicate_data

      # if no predicate data found, return empty file
      if used_predicates.empty?
        @predicate_data = Tempfile.new('predicate_data.tsv')
        return @predicate_data
      end

      # Create hash with key: co_id, value [[predicate_name, predicate_value], ...]
      # prefill with empty values so we have the same number of rows as the main csv, even if some rows don't have
      # data attributes
      empty_hash = collection_object_ids.index_with { |_| []}


      # Pre clean here

      data = (collection_object_attributes + collecting_event_attributes).group_by(&:shift) # very cool

      data = empty_hash.merge(data)

      # write rows to csv
      headers = ::CSV::Row.new(used_predicates, used_predicates, true)

      tbl = ::CSV::Table.new([headers])

      # Get order of ids that matches core records so we can align with csv
      dwc_id_order = collection_object_ids.map.with_index.to_h

      # TODO: this is a heavy-handed hack to re-sync data
      data.delete_if{|k,_| dwc_id_order[k].nil? }

      # TODO: order dependenant pattern is fast but very brittle.
      data.sort_by {|k, _| dwc_id_order[k] }.each do |row|

        # remove collection object id, select "value" from hash conversion
        row = row[1]

        # Create empty row, this way we can insert columns by their headers, not by order
        csv_row = ::CSV::Row.new(used_predicates, [])

        # Add each [header, value] pair to the row
        row.each do |column_pair|
          unless column_pair.empty?
            csv_row[column_pair[0]] = Utilities::Strings.sanitize_for_csv(column_pair[1])
          end
        end

        tbl << csv_row
      end

      content = tbl.to_csv(col_sep: "\t", encoding: Encoding::UTF_8)

      @predicate_data = Tempfile.new('predicate_data.tsv')
      @predicate_data.write(content)
      @predicate_data.flush
      @predicate_data.rewind
      @predicate_data
    end

    # @return Tempfile
    def all_data
      return @all_data if @all_data

      @all_data = Tempfile.new('data.tsv')

      join_data = [data]

      if predicate_options_present?
        join_data.push(predicate_data)
      end

      if taxonworks_options_present?
        join_data.push(taxonworks_extension_data)
      end

      if join_data.size > 1
        # TODO: might not need to check size at some point.
        # Only join files that aren't empty, prevents paste from adding an empty column header when empty.
        @all_data.write(`paste #{ join_data.filter_map{|f| f.path if f.size > 0}.join(' ')}`)
      else
        @all_data.write(data.read)
      end

      @all_data.flush
      @all_data.rewind
      @all_data
    end

    # rubocop:disable Metrics/MethodLength

    # This is a stub, and only half-heartedly done. You should be using IPT for the time being.
    # @return [Tempfile]
    #   metadata about this dataset
    # See also
    #    https://github.com/gbif/ipt/wiki/resourceMetadata
    #    https://github.com/gbif/ipt/wiki/resourceMetadata#exemplar-datasets
    #
    # TODO: reference biological_resource_extension.csv
    def eml
      return @eml if @eml
      @eml = Tempfile.new('eml.xml')

      # This may need to be logged somewhere
      identifier = SecureRandom.uuid

      # This should be build elsewhere, and ultimately derived from a TaxonWorks::Dataset model
      # !! Order matters in these sections vs. validation !!
      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8', namespace_inheritance: false) do |xml|
        xml['eml'].eml(
          'xmlns:eml' => 'eml://ecoinformatics.org/eml-2.1.1',
          'xmlns:dc' => 'http://purl.org/dc/terms/',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'eml://ecoinformatics.org/eml-2.1.1 http://rs.gbif.org/schema/eml-gbif-profile/1.1/eml-gbif-profile.xsd',
          'packageId' => identifier,
          'system' => 'https://taxonworks.org',
          'scope' => 'system',
          'xml:lang' => 'en'
        ) {
          xml.dataset {
            xml.alternateIdentifier identifier
            xml.title('STUB YOUR TITLE HERE')['xmlns:lang'] = 'en'
            xml.creator {
              xml.individualName {
                xml.givenName 'STUB'
                xml.surName 'STUB'
              }
              xml.organizationName 'STUB'
              xml.electronicMailAddress 'EMAIL@EXAMPLE.COM'
            }
            xml.metadataProvider {
              xml.organizationName 'STUB'
              xml.electronicMailAddress 'EMAIL@EXAMPLE.COM'
              xml.onlineUrl 'STUB'
            }
            xml.associatedParty {
              xml.organizationName 'STUB'
              xml.address {
                xml.deliveryPoint 'SEE address above for other fields'
              }
              xml.role 'distributor'
            }
            xml.pubDate Time.new.strftime('%Y-%m-%d')
            xml.language 'eng'
            xml.abstract {
              xml.para 'Abstract text here.'
            }
            xml.intellectualRights {
              xml.para 'STUB. License here.'
            }
            # ...
            xml.contact {
              xml.organizationName 'STUB'
              xml.address {
                xml.deliveryPoint 'STUB'
                xml.city 'STUB'
                xml.administrativeArea 'STUB'
                xml.postalCode 'STUB'
                xml.country 'STUB'
              }
              xml.electronicMailAddress 'EMAIL@EXAMPLE.COM'
              xml.onlineUrl 'STUB'
            }
            # ...
          } # end dataset
          xml.additionalMetadata {
            xml.metadata {
              xml.gbif {
                xml.dateStamp DateTime.parse(Time.now.to_s).to_s
                xml.hierarchyLevel 'dataset'
                xml.citation('STUB DATASET')[:identifier] = 'Identifier STUB'
                xml.resourceLogoUrl 'SOME RESOURCE LOGO URL'
                xml.formationPeriod 'SOME FORMATION PERIOD'
                xml.livingTimePeriod 'SOME LIVING TIME PERIOD'
                xml[:dc].replaces 'PRIOR IDENTIFIER'
              }
            }
          }
        }
      end

      @eml.write(builder.to_xml)
      @eml.flush
      @eml
    end

    # rubocop:enable Metrics/MethodLength

    def biological_associations_resource_relationship
      return nil if biological_associations_extension.nil?
      @biological_associations_resource_relationship = Tempfile.new('biological_resource_relationship.xml')

      content = nil

      if no_records?
        content = "\n"
      else
        content = Export::CSV::Dwc::Extension::BiologicalAssociations.csv(biological_associations_extension)
      end

      @biological_associations_resource_relationship.write(content)
      @biological_associations_resource_relationship.flush
      @biological_associations_resource_relationship.rewind
      @biological_associations_resource_relationship
    end

    # @return [Array]
    #   use the temporarily written, and refined, CSV file to read off the existing headers
    #   so we can use them in writing meta.yml
    # id, and non-standard DwC colums are handled elsewhere
    def meta_fields
      return [] if no_records?
      h = File.open(all_data, &:gets)&.strip&.split("\t")
      h&.shift
      h || []
    end

    def meta
      return @meta if @meta

      @meta = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location 'data.tsv'
            }
            xml.id(index: 0)
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i+1, term: h)
              else
                xml.field(index: i+1, term: DwcOccurrence::DC_NAMESPACE + h)
              end
            end
          }
        }
      end

      @meta.write(builder.to_xml)
      @meta.flush
      @meta
    end

    def build_zip
      t = Tempfile.new(filename)

      Zip::OutputStream.open(t) { |zos| }

      Zip::File.open(t.path, Zip::File::CREATE) do |zip|
        zip.add('data.tsv', all_data.path)

        zip.add('media.csv', media.path) if media_extension
        zip.add('resource_relationships.tsv', biological_associations_resource_relationship.path) if biological_associations_extension

        zip.add('meta.xml', meta.path)
        zip.add('eml.xml', eml.path)
      end
      t
    end

    # @return [Tempfile]
    #   the zipfile
    def zipfile
      if @zipfile.nil?
        @zipfile = build_zip
      end
      @zipfile
    end

    # @return [String]
    # the name of zipfile
    def filename
      @filename ||= "dwc_occurrences_#{DateTime.now}.zip"
      @filename
    end

    # @return [True]
    #   close and delete all temporary files
    def cleanup
      zipfile.close
      zipfile.unlink
      meta.close
      meta.unlink
      eml.close
      eml.unlink
      data.close
      data.unlink

      if biological_associations_extension
        biological_associations_resource_relationship.close
        biological_associations_resource_relationship.unlink
      end

      if predicate_options_present?
        predicate_data.close
        predicate_data.unlink
      end

      if taxonworks_options_present?
        taxonworks_extension_data.close
        taxonworks_extension_data.unlink
      end

      all_data.close
      all_data.unlink
      true
    end

    # @param download [Download instance]
    # @return [Download] a download instance
    def package_download(download)
      download.update!(source_file_path: zipfile.path)
      download
    end

  end
end
