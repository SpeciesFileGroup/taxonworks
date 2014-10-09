class ContentsController < ApplicationController
  include DataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_content, only: [:show, :edit, :update, :destroy]

  # GET /contents
  # GET /contents.json
  def index
    @recent_objects = Content.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /contents/1
  # GET /contents/1.json
  def show
  end

  # GET /contents/new
  def new
    @content = Content.new
  end

  # GET /contents/1/edit
  def edit
  end

  # POST /contents
  # POST /contents.json
  def create
    @content = Content.new(content_params)

    respond_to do |format|
      if @content.save
        format.html { redirect_to @content.becomes(Content), notice: 'Content was successfully created.' }
        format.json { render :show, status: :created, location: @content.becomes(Content) }
      else
        format.html { render :new }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contents/1
  # PATCH/PUT /contents/1.json
  def update
    respond_to do |format|
      if @content.update(content_params)
        format.html { redirect_to @content.becomes(Content), notice: 'Content was successfully updated.' }
        format.json { render :show, status: :ok, location: @content.becomes(Content) }
      else
        format.html { render :edit }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.json
  def destroy
    @content.destroy
    respond_to do |format|
      format.html { redirect_to contents_url }
      format.json { head :no_content }
    end
  end

  def list
    @contents = Content.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    redirect_to content_path(params[:content][:id])
  end

  def autocomplete
    @contents = Content.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @contents.collect do |t|
      {id:              t.id,
       label:           ContentsHelper.taxon_works_content_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      ContentsHelper.taxon_works_content_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_content
    @content = Content.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def content_params
    params.require(:content).permit(:text, :otu_id, :topic_id, :type)
  end
end
