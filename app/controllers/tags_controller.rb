class TagsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_tag, only: [:update, :destroy]

  def new
    if !Keyword.with_project_id(sessions_current_project_id).any? # if there are none
      @return_path = "/tags/new?tag[tag_object_attribute]=&tag[tag_object_id]=#{params[:tag][:tag_object_id]}&tag[tag_object_type]=#{params[:tag][:tag_object_type]}"
      redirect_to new_controlled_vocabulary_term_path(return_path: @return_path), notice: 'Create a keyword or two first!' and return
    end

    @taggable_object = taggable_object
  end

  # GET /tags
  # GET /tags.json
  def index
    @recent_objects = Tag.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  def tag_object_update 
    taggable_object.update(taggable_object_params)
    redirect_to :back
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)
    # redirect_url = (request.env['HTTP_REFERER'].include?(new_tag_path) ? @tag : :back)
    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag.tag_object.metamorphosize, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html {
          redirect_to :back, notice: 'Tag was NOT successfully created.'
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
        format.html { redirect_to @tag.tag_object.metamorphosize, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { redirect_to :back, notice: 'Tag was NOT successfully updated.' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @tags = Tag.where(project_id: sessions_current_project_id).order(:id).page(params[:page])
  end

  # GET /tags/search
  def search
    if params[:id].blank?
      redirect_to tags_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to tag_path(params[:id])
    end
  end

  def autocomplete
    @tags = Queries::TagAutocompleteQuery.new(params.require(:term), project_id: sessions_current_project_id).all

    data = @tags.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.tag_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.tag_tag(t)
      }
    end

    render :json => data
  end

  # GET /tags/download
  def download
    send_data Download.generate_csv(Tag.where(project_id: sessions_current_project_id)), type: 'text', filename: "tags_#{DateTime.now.to_s}.csv"
  end

  private

  def set_tag
    @tag = Tag.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:keyword_id, :tag_object_id, :tag_object_type, :tag_object_attribute)
  end

  def taggable_object_params
    params.require(:taggable_object).permit(
      tags_attributes: [:_destroy, :id, :keyword_id, :position,
                        keyword_attributes: [:name, :definition, :uri, :html_color]

    ])
  end

  def taggable_object
    params.require(:tag_object_type).constantize.find(params.require(:tag_object_id))
  end
 
end

