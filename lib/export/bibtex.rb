require 'zip'

module Export

  # Exports to a simple format.
  module Bibtex 

    DESCRIPTION = "A zip file containing a .bib export sources."

    def self.export(sources, style_id)
      zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_bibtex.bib"

      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
        t = style_id ? ::TaxonWorks::Vendor::BibtexRuby.styled(sources, style_id).join("\n\n") : ::TaxonWorks::Vendor::BibtexRuby.bibliography(sources)
        zipfile.get_output_stream('bibliography.bib') { |f| f.write t }
      end

      zip_file_path
    end

    def self.download(sources, request = nil, is_public = false, style_id = 'http://www.zotero.org/styles/bibtex')
      file_path = ::Export::Bibtex.export(sources, style_id)

      ::Download::Bibtex.create!(
        name: name,
        description: DESCRIPTION,
        filename: filename,
        source_file_path: file_path,
        request: request,
        expires: 2.days.from_now,
        is_public: is_public
      )
    end
   
   #  # HUH
   #def self.download_async(sources, request = nil, is_public = false, style_id = 'http://www.zotero.org/styles/bibtex')
   #  download = ::Download.create!(
   #    name: name,
   #    description: DESCRIPTION,
   #    filename: filename,
   #    request: request,
   #    expires: 2.days.from_now,
   #    is_public: is_public
   # )

   #  # HUH
   #  BasicNomenclatureCreateDownloadJob.perform_later(taxon_name, download)

   #  download
   #end

    def self.name
      "Bibtex export on #{Time.now}."
    end

    def self.filename
      "bibtex_#{DateTime.now}.zip"
    end

  end
end
