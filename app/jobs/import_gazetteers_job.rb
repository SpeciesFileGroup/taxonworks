class ImportGazetteersJob < ApplicationJob
  queue_as :import_gazetteers

  def perform(
    shapefile, citation_options, uid, project_id, progress_tracker, projects
  )
    Current.user_id = uid
    Current.project_id = project_id

    Gazetteer.import_gzs_from_shapefile(
      shapefile, citation_options, progress_tracker, projects
    )
  end

end
