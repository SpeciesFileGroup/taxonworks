require 'zip'

module Export::Dwca

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

    attr_accessor :core_scope

    attr_accessor :biological_extension_scope

    attr_accessor :total #TODO update

    attr_reader :filename

    # @param [Hash] args
    def initialize(core_scope: nil, extension_scopes: {} )
      # raise ArgumentError, 'must pass a core_scope' if !record_core_scope.kind_of?( ActiveRecord::Relation )
      @core_scope = get_scope(core_scope)
      @biological_extension_scope = extension_scopes[:biological_extension_scope] #  = get_scope(core_scope)
    end

    def total
      @total ||= core_scope.size
    end

    # @return [CSV]
    #   the data as a CSV object
    def csv
      ::Export::Download.generate_csv(
        core_scope.computed_columns,
        exclude_columns: ::DwcOccurrence.excluded_columns,
        trim_columns: true, # going to have to be optional
        trim_rows: false,
        header_converters: [:dwc_headers]
      )
    end

    # @return [Array]
    #   use the temporarily written, and refined, CSV file to read off the existing headers
    def csv_headers
      return [] if no_records?
      d = CSV.open(data, headers: true, col_sep: "\t")
      d.read
      h = d.headers
      d.rewind
      h.shift # get rid of id, it's special in meta
      h
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

      @data = Tempfile.new('data.csv')
      @data.write(content)
      @data.flush
      @data.rewind
      @data
    end

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
      builder = Nokogiri::XML::Builder.new do |xml|
        xml['eml'].eml(
          'xmlns:eml' => 'eml://ecoinformatics.org/eml-2.1.1',
          'xmlns:dc' => 'http://purl.org/dc/terms/',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'eml://ecoinformatics.org/eml-2.1.1 http://rs.gbif.org/schema/eml-gbif-profile/1.1/eml.xsd',
          'packageId' => identifier,
          'system' => 'http://taxonworks.org',
          'core_scope' => 'system',
          'xml:lang' => 'eng'
        ) {
          xml.dataset {
            xml.alternate_identifier identifier
            xml.title('xml:lang' => 'eng').text 'STUB - YOUR TITLE HERE'
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
              xml.onlineURL 'STUB'
            }
            xml.pubDate Time.new.strftime('%Y-%m-%d')
            xml.language 'eng'
            xml.abstract {
              xml.para 'Abstract text here.'
            }
            # ...
            xml.contact {
              xml.organizationName 'STUB'
              xml.electronicMailAddress 'EMAIL@EXAMPLE.COM'
              xml.onlineURL 'STUB'
            }
            # ...
            xml.additionalMetadata {
              xml.metadata {
                xml.gbif {
                  xml.dateStamp
                  xml.hierarchyLevel
                  xml.citation(identifier: 'STUB').text 'DATASET CITATION STUB'
                  xml.resourceLogoURL 'SOME RESOURCE LOGO URL'
                  xml.formationPeriod 'SOME FORMAATION PERIOD'
                  xml.livingTimePeriod 'SOME LIVINGI TIME PERIOD'
                  xml[:dc].replaces 'PRIOR IDENTIFIER'
                }
              }
            }
          }
        }
      end

      @eml.write(builder.to_xml)
      @eml.flush
      @eml
    end

    def biological_resource_relationship 
      return nil if biological_extension_scope.nil?
      @biological_resource_relationship = Tempfile.new('biological_resource_relationship.xml')

      content = nil
      if no_records?
        content = "\n"
      else
        content = ::Export::Download.generate_csv(
          biological_extension_scope.computed_columns,
          #          exclude_columns: []
          trim_columns: false,
          trim_rows: false,
          header_converters: []
        )
      end

      @biological_resource_relationship.write(content)
      @biological_resource_relationship.flush
      @biological_resource_relationship.rewind
      @biological_resource_relationship
    end

    def meta
      return @meta if @meta

      @meta = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location 'data.csv'
            }
            xml.id(index: 0)
            csv_headers.each_with_index do |h,i|
              xml.field(index: i+1, term: DwcOccurrence::DC_NAMESPACE + h)
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
        zip.add('data.csv', data.path)
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

    # File.read(@zipfile.path)

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
      true
    end

    # params core_scope [String, ActiveRecord::Relation]
    #   string is fully formed SQL
    def get_scope(scope)
      if scope.kind_of?(String)
        DwcOccurrence.from('(' + scope + ') as dwc_occurrences')
      elsif scope.kind_of?(ActiveRecord::Relation)
        scope
      else
        raise ArgumentError, 'Scope is not a SQL string or ActiveRecord::Relation'
      end
    end

    # @param download [Download instance]
    # @return [Download] a download instance
    def package_download(download)
      download.update!(source_file_path: zipfile.path)
      download
    end

  end
end
