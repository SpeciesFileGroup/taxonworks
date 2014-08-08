class TagsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    #@tags           = Tag.all
    @recent_objects = Tag.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)

  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # triggered by "list" link on index page
  def list
    @tags = Tag.order(:id).page(params[:page])
  end

# POST /tags
  # POST /tags.json
  def create
    @tag         = Tag.new(tag_params)
    redirect_url = (request.env['HTTP_REFERER'].include?(new_tag_path) ? @tag : :back)
    respond_to do |format|
      if @tag.save
        format.html { redirect_to redirect_url, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html {
          if redirect_url == :back
            redirect_to redirect_url
          else
            render :new
          end
        }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    redirect_url = (request.env['HTTP_REFERER'].include?("tags/#{@tag.id}") ? tags_url : :back)
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    redirect_to tag_path(params[:tag][:id])
  end

  def autocomplete
    @otus = Tag.find_for_autocomplete(params)

    data = @tags.collect do |t|
      {id:              t.id,
       label:           TagsHelper.tag_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      TagsHelper.tag_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(:keyword_id, :tag_object_id, :tag_object_type, :tag_object_attribute, :created_by_id, :updated_by_id, :project_id, :position)
  end
end
