class BasicNomenclatureCreateDownloadJob < ApplicationJob
  queue_as :basic_nomenclature_export

  def perform(taxon_name, download)
    begin
      download.source_file_path = ::Export::BasicNomenclature.export(taxon_name.id)
      download.save
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { taxon_name: taxon_name&.id&.to_s, download: download&.id&.to_s }
      )
      raise
    end
  end
end
