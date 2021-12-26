# expensive operation during occurrence import that can be postponed to speed up row processing
class DwcOccurrenceCacheGeoreferenceJob < ApplicationJob
  queue_as :dwc_occurrence_cache_georeference

  # @param [Georeference] georeference
  def perform(georeference)
    georeference.send(:set_cached)
  end
end
