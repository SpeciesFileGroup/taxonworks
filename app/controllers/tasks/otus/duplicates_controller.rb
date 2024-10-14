class Tasks::Otus::DuplicatesController < ApplicationController
  include TaskControllerConfiguration

  after_action -> { set_pagination_headers(:otus) }, only: [:data], if: :json_request?

  def index
  end

  def data 
    a = Otu
      .joins(:taxon_name)
      .where('otus.project_id = ?',  sessions_current_project_id)
      .select('otus.id, otus.name, taxon_names.type, taxon_names.cached, count(*) OVER (PARTITION BY otus.name, taxon_names.cached, taxon_names.type) AS count')

    @otus = Otu.with(dupes: a)
      .left_joins(:taxon_name)
      .eager_load(:taxon_name)
      .joins('JOIN dupes on dupes.id = otus.id')
      .select('otus.*, count, dupes.cached')
      .where('count > 1')
      .order('count, name, cached')
      .page(params[:page])
      .per(params[:per])


    render json: @otus.collect{|o| o.attributes.merge(label: helpers.otu_tag(o), global_id: o.to_global_id.to_s) }
  end

end
