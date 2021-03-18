class ImportDatasetImportJob < ApplicationJob
  queue_as :import_dataset_import

  def perform(import_dataset, uuid, max_time, max_records, retry_errored, filters)
    begin
      Current.user_id = import_dataset.created_by_id
      Current.project_id = import_dataset.project_id

      import_dataset.with_lock do
        if import_dataset.metadata['import_uuid'] == uuid
          if import_dataset.import(max_time, max_records, retry_errored: retry_errored, filters: filters).any?
            ImportDatasetImportJob.perform_later(import_dataset, uuid, max_time, max_records, retry_errored, filters)
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