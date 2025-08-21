class Tasks::FieldOccurrences::DwcMediaExtensionPreviewController < ApplicationController
  include TaskControllerConfiguration

  def index
    @field_occurrences_query = ::Queries::FieldOccurrence::Filter.new(params)
    @field_occurrences = @field_occurrences_query.all.order(:id).page(params[:page]).per(params[:per])
  end

end
