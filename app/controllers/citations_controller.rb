# require_dependency Rails.root.to_s + '/lib/queries/citation/filter'

class CitationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_citation, only: [:update, :destroy, :show]
  after_action -> { set_pagination_headers(:citations) }, only: [:index, :api_index ], if: :json_request?

  # GET /citations
  # GET /citations.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Citation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @citations = ::Queries::Citation::Filter.new(params).all.where(project_id: sessions_current_project_id).includes(:source)
          .order(:source_id, :pages)
          .page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  def new
    @citation = Citation.new(citation_params)
  end

  def edit
    @citation = Citation.find_by_id(params[:id]).metamorphosize
  end

  # Presently only used in autocomplete
  def show
    respond_to do |format|
      format.html {
        redirect_to url_for(@citation.annotated_object.metamorphosize)
      }
      format.json {}
    end
  end

  # POST /citations
  # POST /citations.json
  def create
    @citation = Citation.new(citation_params)
    respond_to do |format|
      if @citation.save
        format.html {redirect_to url_for(@citation.citation_object.metamorphosize), notice: 'Citation was successfully created.'}
        format.json {render :show, status: :created, location: @citation}
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Citation was NOT successfully created.')}
        format.json {render json: @citation.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /citations/1
  # PATCH/PUT /citations/1.json
  def update
    respond_to do |format|
      if @citation.update(citation_params)
        format.html {redirect_to url_for(@citation.citation_object.metamorphosize), notice: 'Citation was successfully updated.'}
        format.json {render :show, location: @citation}
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Citation was NOT successfully updated.')}
        format.json {render json: @citation.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /citations/1
  # DELETE /citations/1.json
  def destroy
    @citation.destroy
    respond_to do |format|
      if @citation.destroyed?
        format.html { destroy_redirect @citation, notice: 'Citation was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @citation, notice: 'Citation was not destroyed, ' + @citation.errors.full_messages.join('; ') }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    @citations = Citation.with_project_id(sessions_current_project_id).order(:citation_object_type).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to citations_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to citation_path(params[:id])
    end
  end

  def autocomplete
    @citations = Citation.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @citations.collect do |t|
      lbl = render_to_string(partial: 'tag', locals: {citation: t})
      {id: t.id,
       label: lbl,
       response_values: {
         params[:method] => t.id
       },
       label_html: lbl
      }
    end

    render json: data
  end

  # GET /citations/download
  def download
    send_data Export::Download.generate_csv(Citation.where(project_id: sessions_current_project_id)), type: 'text', filename: "citations_#{DateTime.now}.csv"
  end

  def api_index
    @citations = Queries::Citation::Filter.new(params).all
      .where(project_id: sessions_current_project_id).includes(:source)
      .order('sources.cached, sources.pages')
      .page(params[:page]).per(params[:per] || 50)     ### error when 500 !!

    @verbose_object = params[:verbose_object]
    render '/citations/api/v1/index'
  end

  def api_show
    @citation = Citation.where(project_id: sessions_current_project_id).find(params[:id])
    render '/citations/api/v1/show'
  end

  private

  def set_citation
    @citation = Citation.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def citation_params
    params.require(:citation).permit(
      :citation_object_type, :citation_object_id, :source_id, :pages, :is_original,
      :annotated_global_entity, :user_id,
      citation_topics_attributes: [
        :id, :_destroy, :pages, :topic_id,
        topic_attributes: [:id, :_destroy, :name, :definition]
      ],
      topics_attributes: [:name, :definition]
    )
  end

end
