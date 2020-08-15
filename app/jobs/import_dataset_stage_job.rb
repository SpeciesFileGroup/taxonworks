class ImportDatasetStageJob < ApplicationJob
  queue_as :import_dataset_stage

  def perform(import_dataset)
    begin
      Current.user_id = import_dataset.created_by_id
      Current.project_id = import_dataset.project_id

      import_dataset.stage
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { import_dataset: import_dataset&.id&.to_s }
      )
      raise
    end
  end
end
