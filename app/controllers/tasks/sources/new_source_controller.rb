class Tasks::Sources::NewSourceController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  # GET /sources/new_source/crossref_preview.json
  def crossref_preview
    if citation_param.blank?
      render json: :invalid_request
    else
      @source = Vendor::Serrano.new_from_citation(citation: citation_param)
      @source ||= Source::Bibtex.new
      render '/sources/show'
    end
  rescue Vendor::Serrano::CrossrefBibtexParseError => e
    render json: {
      error: 'Crossref returned BibTeX that could not be parsed.',
      doi: e.doi,
      bibtex: e.bibtex
    }, status: :unprocessable_content
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
