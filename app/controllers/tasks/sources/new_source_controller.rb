class Tasks::Sources::NewSourceController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def crossref_preview
    if citation_param.blank?
      render json: :invalid_request
    else
      @source = TaxonWorks::Vendor::Serrano.new_from_citation(citation: citation_param)
      render '/sources/show'
    end
  end

  protected

  def citation_param
    begin
      params.require(:citation)
    rescue ActionController::ParameterMissing
      nil
    end
  end

end
