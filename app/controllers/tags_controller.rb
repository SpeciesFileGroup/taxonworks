require_dependency 'queries/tag/filter'

class TagsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_tag, only: [:update, :destroy]
  after_action -> { set_pagination_headers(:tags) }, only: [:index, :api_index ], if: :json_request?

  # GET /tags
  # GET /tags.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = ::Tag.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @tags = ::Queries::Tag::Filter.new(params).all.where(project_id: sessions_current_project_id).
        page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  def new
    if !Keyword.with_project_id(sessions_current_project_id).any? # if there are none
      @return_path = "/tags/new?tag[tag_object_attribute]=&tag[tag_object_id]=#{params[:tag_object_id]}" \
        "&tag[tag_object_type]=#{params[:tag_object_type]}"
      redirect_to new_controlled_vocabulary_term_path(return_path: @return_path),
        notice: 'Create a keyword or two first!' and return
    end

    @taggable_object = taggable_object
  end

  def tag_object_update
    taggable_object.update!(taggable_object_params)
    redirect_back(fallback_location: (request.referer || root_path))
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)
    respond_to do |format|
      if @tag.save
        format.html { redirect_to url_for(@tag.tag_object.metamorphosize),
                      notice: "Tag #{@tag.keyword.name} was successfully created." }
        format.json { render action: 'show', status: :created, location: @tag }
      else
        format.html {
          redirect_back(fallback_location: (request.referer || root_path),
                        notice: 'Tag was NOT successfully created.')
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
        format.html { redirect_to url_for(@tag.tag_object.metamorphosize),
                      notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path),
                                    notice: 'Tag was NOT successfully updated.') }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy!
    respond_to do |format|
      # TODO: probably needs to be changed with new annotator
      format.html { redirect_back(fallback_location: (request.referer || root_path),
                                  notice: 'Tag was successfully destroyed.') }
      format.json { head :no_content }
    end
  end

  def list
    @tags = Tag.where(project_id: sessions_current_project_id).order(:id).page(params[:page])
  end

  def exists
    if @tag = Tag.exists?(params.require(:global_id),
        params.require(:keyword_id),
        sessions_current_project_id)
      render :show
    else
      render json: false
    end
  end

  # GET /tags/download
  def download
    send_data Export::Download.generate_csv(Tag.where(project_id: sessions_current_project_id)),
      type: 'text', filename: "tags_#{DateTime.now}.csv"
  end

  # POST /tags/batch_remove?keyword_id=123&klass=456
  def batch_remove
    if Tag.batch_remove(params.require(:keyword_id), params.require(:klass))
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  # POST /tags/batch_create.json?keyword_id=123&object_type=CollectionObject&object_ids[]=123
  def batch_create
    if Tag.batch_create(
        params.permit(:keyword_id, :object_type, object_ids: []).to_h.merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).symbolize_keys
    )
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private

  def set_tag
    @tag = Tag.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(
      :keyword_id, :tag_object_id, :tag_object_type, :tag_object_attribute, :annotated_global_entity, :_destroy,
      keyword_attributes: [:name, :definition, :uri, :uri_relation, :css_color]
    )
  end

  def taggable_object_params
    params.require(:taggable_object).permit(
      tags_attributes: [:_destroy, :id, :keyword_id, :position,
                        keyword_attributes: [:name, :definition, :uri, :html_color]

    ])
  end

  def taggable_object
    whitelist_constantize(params.require(:tag_object_type)).find(params.require(:tag_object_id))
  end

end

