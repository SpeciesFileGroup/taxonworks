require 'dwc_archive'

module Export
  module Dwca
    # Generates a DwC-A from database data

    # @return [String]
    def self.get_archive(download, scope)
      records = get_records(scope)

      data = nil
      begin

        a.build_zip
        return a.zipfile.path
      ensure
        a.cleanup
      end

      #path = Rails.root.join('tmp/dwc_' + SecureRandom.hex + '.tar.gz')
      #gen = DarwinCore::Generator.new(path)

      #  # TODO: build out the core
      #  # header ... columns
      # 
      #  core = [['http://rs.tdwg.org/dwc/terms/taxonID']] # -> get stuf?!

      #  gen.add_core(core, 'core.txt')
      #  gen.add_meta_xml
      #  gen.pack
      #  gen.clean

     #  return data.path
    end



    # @param record_scope [ActiveRecord::Relation]
    #   a relation return DwcOccurrence records
    def self.download_async(record_scope, request = nil)
      name = "dwc-a_#{DateTime.now}.zip"

      download = ::Download.create!(
        name: "DwC Archive generated at #{Time.now}.",
        description: 'A Darwin Core archive.',
        filename: name,
        request: request,
        expires: 2.days.from_now
      )

      DwcaCreateDownloadJob.perform_later(download, record_scope.to_sql)

      download
    end



  end
end
