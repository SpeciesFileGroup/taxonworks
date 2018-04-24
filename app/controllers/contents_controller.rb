class ContentsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_content, only: [:show, :edit, :update, :destroy]

  # GET /contents
  # GET /contents.json
  # @return [Ignored]
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Content.where(project_id: sessions_current_project_id).recently_updated(10)
        render '/shared/data/all/index'
      end
      format.json {
        @contents = filtered_content
      }
    end
  end

  # GET /contents/1
  # GET /contents/1.json
  # @return [Ignored]
  def show
  end

  # GET /contents/new
  # @return [Ignored]
  def new
    @content = Content.new
  end

  # GET /contents/1/edit
  # @return [Ignored]
  def edit
  end

  # POST /contents
  # POST /contents.json
  # @return [Ignored]
  def create
    @content = Content.new(content_params)

    respond_to do |format|
      if @content.save
        format.html { redirect_to url_for(@content.metamorphosize), notice: 'Content was successfully created.' }
        format.json { render :show, status: :created, location: @content.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contents/1
  # PATCH/PUT /contents/1.json
  # @return [Ignored]
  def update
    respond_to do |format|
      if @content.update(content_params)
        format.html { redirect_to url_for(@content.metamorphosize), notice: 'Content was successfully updated.' }
        format.json { render :show, status: :ok, location: @content.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.json
  # @return [Ignored]
  def destroy
    @content.destroy!
    respond_to do |format|
      format.html { redirect_to contents_url }
      format.json { head :no_content }
    end
  end

  # @return [Ignored]
  def list
    @contents = Content.with_project_id(sessions_current_project_id).order(:id).page(params[:page])
  end

  # @return [Ignored]
  def search
    if params[:id].blank?
      redirect_to content_path,
                  notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to content_path(params[:id])
    end
  end

  # GET /contents/filter.json
  # @return [Ignored]
  def filter
    @contents = filtered_content
    render '/contents/index'
  end

  # @return [JSON]
  def autocomplete
    @contents = Content.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @contents.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.taxon_works_content_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.taxon_works_content_tag(t)
      }
    end

    render json: data
  end

  # GET /contents/download
  # @return [Ignored]
  def download
    send_data(Download.generate_csv(Content.where(project_id: sessions_current_project_id)),
              type:     'text',
              filename: "contents_#{DateTime.now}.csv")
  end

  private

  # @return [ActionController::Parameters]
  def filtered_content
    p =  params.permit(:otu_id, :topic_id, :hours_ago, :most_recent_updates).to_h.symbolize_keys
    p[:most_recent_updates] = 10 if p.empty?
    Queries::ContentFilterQuery.new(p)
      .all
      .with_project_id(sessions_current_project_id)
  end

  # @return [Ignored]
  def set_content
    @content = Content.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @content
  end

  # @return [ActionController::Parameters]
  def content_params
    params.require(:content).permit(:text, :otu_id, :topic_id, :type)
  end
end
