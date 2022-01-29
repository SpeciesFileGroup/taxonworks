class ImportDatasetImportJob < ApplicationJob
  queue_as :import_dataset_import

  def perform(import_dataset, uuid, max_time, max_records)
    begin
      Current.user_id = import_dataset.created_by_id
      Current.project_id = import_dataset.project_id

      import_dataset.with_lock do
        metadata = import_dataset.metadata
        if metadata['import_uuid'] == uuid
          if import_dataset.import(max_time, max_records).any?
            ImportDatasetImportJob.perform_later(import_dataset, uuid, max_time, max_records)
          end
        end
      end
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { import_dataset: import_dataset&.id&.to_s }
      )
      raise
    end
  end
end