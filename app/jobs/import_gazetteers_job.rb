class ImportGazetteersJob < ApplicationJob
  queue_as :import_gazetteers

  def perform(shapefile, uid, project_id, progress_tracker)
    Current.user_id = uid
    Current.project_id = project_id

    Gazetteer.import_from_shapefile(shapefile, progress_tracker)
  end

end
