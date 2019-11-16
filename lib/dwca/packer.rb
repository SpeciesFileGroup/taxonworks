require 'zip'

module Dwca::Packer

  # Wrapper to build DWCA zipfiles for a specific project.
  # See tasks/accesssions/report/dwc_controller.rb for use.
  #
  # With help from http://thinkingeek.com/2013/11/15/create-temporary-zip-file-send-response-rails/
  #
  # Usage:
  #  begin
  #   data = Dwca::Packer::Data.new(DwcOccurrence.where(project_id: sessions_current_project_id)
  #  ensure
  #   data.cleanup
  #  end
  #
  # Always use the ensure/data.cleanup pattern!
  #
  class Data
    attr_accessor :data, :eml, :meta, :zipfile, :scope, :total
    attr_reader :filename

    # @param [Hash] args
    def initialize(record_scope)
      raise ArgumentError, 'must pass a scope' if !record_scope.kind_of?( ActiveRecord::Relation )
      @scope = record_scope
      @total = scope.count('*')
    end

    # @return [CSV]
    #   the data as a CSV object
    def csv
      Export::Download.generate_csv(
        scope.computed_columns,
        trim_columns: true,
        trim_rows: true,
        header_converters: [:dwc_headers]
      )
    end

    # @return [Array]
    #   use the temporarily written, and refined, CSV file to read of the existing headers
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
    #   true if provided scope returns no records
    def no_records?
      total == 0
    end

    # @return [Tempfile]
    #    the csv data as a tempfile
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
          'scope' => 'system',
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
                  xml.resourceLogoURL 'SOME URL'
                  xml.formationPeriod 'SOME PERIOD'
                  xml.livingTimePeriod 'SOME PERIOD'
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

    # @return [Tempfile]
    #   the actual data file
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

    # @return [File]
    #   the stream to use in send_data, for example
    def getzip
      Zip::OutputStream.open(zipfile) { |zos| }

      Zip::File.open(zipfile.path, Zip::File::CREATE) do |zip|
        zip.add('data.csv', data.path)
        zip.add('meta.xml', meta.path)
        zip.add('eml.xml', eml.path)
      end

      File.read(zipfile.path)
    end

    # @return [Tempfile]
    #   the zipfile
    def zipfile
      @zipfile ||= Tempfile.new(filename)
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
      true
    end

  end
end
