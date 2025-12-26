require 'zip'

module Export::Dwca

  class ChecklistData

    # @return [Hash] of Otu query params
    #  Required.
    attr_accessor :core_otu_scope

    # @return [Scope] of DwcOccurrence
    # Derived from core_otu_scope
    attr_accessor :core_occurrence_scope

    # Size of core_scope
    attr_accessor :total

    attr_accessor :zipfile

    # Name of the @zipfile
    attr_reader :filename

    attr_accessor :meta

    attr_accessor :eml

    attr_accessor :data_file

    def initialize(core_scope: nil)
      @core_otu_scope = core_scope

      @core_occurrence_scope = ::Queries::DwcOccurrence::Filter.new(
        otu_query: core_scope
      ).all.order(:id)
    end

    # @return [Array]
    #   use the temporarily written, and refined, CSV file to read off the existing headers
    #   so we can use them in writing meta.yml
    # non-standard DwC colums are handled elsewhere
    def meta_fields
      return [] if no_records?
      h = File.open(all_data, &:gets)&.strip&.split("\t")
      h&.shift # shift because the first column, id, will be specified by hand
      h || []
    end

    def total
      @total ||= core_scope.unscope(:order).size
    end

    # @return [Boolean]
    #   true if provided core_scope returns no records
    def no_records?
      total == 0
    end

    # @return [CSV]
    #   the data as a CSV object
    def csv
      ::Export::CSV.generate_csv(
        core_scope.computed_checklist_columns,
        exclude_columns: ::DwcOccurrence.excluded_checklist_columns,
        column_order: ::CollectionObject::DWC_OCCURRENCE_MAP.keys + ::CollectionObject::EXTENSION_FIELDS, # TODO: add other maps here
        trim_columns: true, # going to have to be optional
        trim_rows: false,
        header_converters: [:dwc_headers],
        copy_column: { from: 'occurrenceID', to: 'id' }
      )
    end

    # @return [Tempfile]
    #   the csv data as a tempfile
    def data_file
      return @data_file if @data_file

      if no_records?
        content = "\n"
      else
        content = csv
      end

      @data_file = Tempfile.new('data.tsv')
      @data_file.write(content)
      @data_file.flush
      @data_file.rewind

      Rails.logger.debug 'dwca_checklist_export: data written'

      @data_file
    end

    # This is a stub, and only half-heartedly done. You should be using IPT for
    # the time being.
    # @return [Tempfile]
    #   metadata about this dataset
    # See also
    #    https://github.com/gbif/ipt/wiki/resourceMetadata
    #    https://github.com/gbif/ipt/wiki/resourceMetadata#exemplar-datasets
    #
    def eml
      return @eml if @eml

      @eml = Tempfile.new('eml.xml')

      eml_xml = ::Export::Dwca::Eml.actualized_stub_eml

      @eml.write(eml_xml)
      @eml.flush
      @eml
    end

    def meta
      return @meta if @meta

      @meta = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          # Core
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location 'data.tsv'
            }
            xml.id(index: 0) # Must be named id (?)
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i+1, term: h)
              else
                xml.field(index: i+1, term: DwcOccurrence::DC_NAMESPACE + h)
              end
            end
          }

          # Resource relationship (biological associations)
          if !biological_associations_extension.nil?
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/ResourceRelationship') {
              xml.files {
                xml.location 'resource_relationships.tsv'
              }
              Export::CSV::Dwc::Extension::BiologicalAssociations::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First resource relationship column (coreid) should have namespace '', got '#{n}'")
                  xml.coreid(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end

          # Media (images, sounds)
          if !media_extension.nil?
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/ac/terms/Multimedia') {
              xml.files {
                xml.location 'media.tsv'
              }
              Export::CSV::Dwc::Extension::Media::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First media column (coreid) should have namespace '', got '#{n}'")
                  xml.coreid(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end
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
        zip.add('data.tsv', data_file.path)

        zip.add('media.tsv', media_tmp.path) if media_extension
        zip.add('resource_relationships.tsv', biological_associations_resource_relationship_tmp.path) if biological_associations_extension

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
      @filename ||= "dwc_checklist_#{DateTime.now}.zip"
      @filename
    end


    # @param download [a Download]
    def package_download(download)
      p = zipfile.path

      # This doesn't touch the db (source_file_path is an instance var).
      download.update!(source_file_path: p)
    end
  end
end