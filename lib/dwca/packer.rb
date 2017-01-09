module Dwca::Packer

  # Wrapper to build DWCA zipfiles for a specific project.
  # See tasks/accesssions/report/dwc_controller.rb for use.
  #
  # With help from http://thinkingeek.com/2013/11/15/create-temporary-zip-file-send-response-rails/
  class Data
    attr_accessor :data, :meta, :dataset_meta, :zipfile, :project_id
    attr_reader :filename

    def initialize(project_id)
      raise if project_id.nil?
      @project_id = project_id 
    end

    def csv
      Download.generate_csv(
        DwcOccurrence.computed_columns.where(project_id: project_id), 
        trim_columns: true, 
        trim_rows: true,
        header_converters: [:dwc_headers]
      )
    end

    def data
      return @data if @data
      @data = Tempfile.new('data.csv')
      @data.write(csv)
      @data.flush
      @data
    end

    #  <?xml version="1.0"?>
    #  <archive xmlns="http://rs.tdwg.org/dwc/text/">
    #    <core encoding="UTF-8" linesTerminatedBy="\r\n" fieldsTerminatedBy="," fieldsEnclosedBy="&quot;" ignoreHeaderLines="1" rowType="http://rs.tdwg.org/dwc/terms/Occurrence">
    #      <files>
    #        <location></location>
    #      </files>
    #      <id index="0"/>
    #      <field index="1" term="http://rs.tdwg.org/dwc/terms/basisOfRecord"/>
    #      <field index="2" term="http://purl.org/dc/terms/type"/>
    #    </core>
    #  </archive>
    def eml
      @eml = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\r\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '&quot;', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location {}
            } 
          }
        } 
      end 

      @eml.write(builder.to_xml) 
      @eml.flush
      @eml 
    end

    # @return [File]
    #   the stream to use in send_data
    def getzip
      Zip::OutputStream.open(zipfile) { |zos| }

      Zip::File.open(zipfile.path, Zip::File::CREATE) do |zip|
        zip.add('data.csv', data.path)    
        zip.add('meta.xml', eml.path)    
      end

      File.read(zipfile.path)
    end

    # @return [Tempfile]
    def zipfile
      @zipfile ||= Tempfile.new(filename)
      @zipfile
    end

   # @return [String]
   # the name of zipfile 
   def filename
      @filename ||= "dwc_occurrences_#{DateTime.now.to_s}.zip"
      @filename 
    end

    def cleanup
      zipfile.close
      zipfile.unlink
      data.close
      data.unlink
      eml.close
      eml.unlink
     # dataset_meta.close
     # dataset_meta.unlink
    end

  end
end
