class Tasks::Confidences::VisualizeController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @for = params[:klass] || 'TaxonName'
  end
end
