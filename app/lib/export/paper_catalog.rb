require 'zip'
require 'asciidoctor'
# require 'asciidoctor-epub3'

module Export
  module PaperCatalog

    def self.export(taxon_name, body = nil, options = {})
      zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_paper_catalog.zip"

      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|

        zipfile.get_output_stream('catalog.md') do |f|
          f.write body
        end

        zipfile.get_output_stream('catalog.html') do |f|
          f.write (Asciidoctor.convert body, safe: :safe, header_footer: true)
        end

        # zipfile.get_output_stream('catalog.epub') do |f|
        #    f.write (Asciidoctor.convert body, backend: 'epub3', safe: :safe)
        # end
      end

      zip_file_path
    end

    # def self.filename(taxon_name)
    #   Zaru::sanitize!("#{::Project.find(Current.project_id).name}_coldp_otu_id_#{otu.id}_#{DateTime.now}.zip").gsub(' ', '_').downcase
    # end

    # def self.download(otu, request = nil, prefer_unlabelled_otus: true)
    #   file_path = ::Export::Coldp.export(
    #     otu.id,
    #     prefer_unlabelled_otus: prefer_unlabelled_otus
    #   )
    #   name = "coldp_otu_id_#{otu.id}_#{DateTime.now}.zip"

    #   ::Download::PaperCatalog.create!(
    #     name: "Paper catalog for #{otu.otu_name} on #{Time.now}.",
    #     description: 'A zip file containing paper catalog formatted data.',
    #     filename: filename(otu),
    #     source_file_path: file_path,
    #     request: request,
    #     expires: 2.days.from_now
    #   )
    # end

    # def self.download_async(otu, request = nil, prefer_unlabelled_otus: true)
    #   download = ::Download::Coldp.create!(
    #     name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
    #     description: 'A zip file containing CoLDP formatted data.',
    #     filename: filename(otu),
    #     request: request,
    #     expires: 2.days.from_now
    #   )

    #   ColdpCreateDownloadJob.perform_later(otu, download, prefer_unlabelled_otus: prefer_unlabelled_otus)

    #   download
    # end

  end
end
