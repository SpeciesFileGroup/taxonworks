require 'dwc_archive'

module Export
  module Dwca

    # Generates a DwC-A from database data
    # @return [String]
    def self.get_archive(scope)
      path = Rails.root.join('tmp/dwc_' + SecureRandom.hex + '.tar.gz')
      gen = DarwinCore::Generator.new(path)

      core = [['http://rs.tdwg.org/dwc/terms/taxonID']] # -> get stuf?!

      gen.add_core(core, 'core.txt')
      gen.add_meta_xml
      gen.pack
      gen.clean

      return path
    end

    def self.download_async(record_scope, request = nil)
      name = "dwc-a_#{DateTime.now}.zip"

      download = ::Download.create!(
        name: "DwC Archive generated at #{Time.now}.",
        description: 'A Darwin Core archive.',
        filename: name,
        request: request,
        expires: 2.days.from_now
      )

      DwcaCreateDownloadJob.perform_later('1' , download)

      download
    end

  end
end
