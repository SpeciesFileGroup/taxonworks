class DwcaCreateDownloadJob < ApplicationJob
  queue_as :dwca_export

  # @param scope [String, ActiveRecord::Relation]
  #   String of SQL generated from the scope 
  #   SQL must  return a list of DwcOccurrence records
  # take a download, and a list of scopes, and save the result to the download, that's all
  def perform(download, scope = nil)
 #   ::Export::Dwca.
 #    begin
 #      d = ::Export::Dwca.get_archive(scope)
 #      a = ::Export::Dwca::Data.new(records)

 #      download.source_file_path =         download.save
 #    ensure

 #    end
 #  rescue => ex
 #    ExceptionNotifier.notify_exception(ex, data: {  download: download&.id&.to_s } ) # otu: otu&.id&.to_s,
 #    raise
 #  end
  end

end
