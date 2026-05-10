class Tasks::Otus::MaterialExaminedController < ApplicationController
  include TaskControllerConfiguration

  MAX_OTUS = 100

  def index
  end

  # POST /tasks/otus/material_examined/preview.json
  def preview
    otu_ids = params[:otu_id].to_a.first(MAX_OTUS).map(&:to_i).uniq.compact

    results = otu_ids.map do |otu_id|
      otu = ::Otu.where(project_id: sessions_current_project_id).find(otu_id)
      text = ::Export::Helpers::MaterialExamined.render_for_otu(otu)
      { otu_id: otu.id, label: helpers.label_for_otu(otu), text: }
    end

    render json: { results: }
  end

end
