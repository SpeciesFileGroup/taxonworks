# This controller scopes to News::Project classes for show and index.
#
# See the related Administration controller for Administration news scoping of show and index.
#
# Create/udpate scoping to Administrators is handled in the model.
#
class NewsController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_news, only: %i[ show edit update destroy ]

  after_action -> { set_pagination_headers(:news) }, only: [:index, :api_index], if: :json_request?

  # GET /news or /news.json
  def index

    respond_to do |format|
      # We use the "Newspaper" for displaying news
      format.html do
        redirect_to :browse_news_task  and return
      end
      format.json {
        @news = News::Project.where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
          .order(:display_start, :created_at)
      }
    end
  end

  # Serves only current blog_posts at the moment
  def api_index
    @news = News::Project::BlogPost
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
      .order(:display_start, :created_at)

    render '/news/api/v1/index'
  end

  # Serves only current blog_posts at the moment
  def api_show
    @news = News::Project::BlogPost.find(params[:id])
    render '/news/api/v1/show'
  end

  # GET /news/1 or /news/1.json
  def show
  end

  # GET /news/new
  def new
    @news = News.new
  end

  # GET /news/1/edit
  def edit
  end

  # POST /news or /news.json
  def create
    @news = News.new(news_params)

    respond_to do |format|
      if @news.save
        format.html { redirect_to @news.becomes(@news.class.base_class), notice: 'News was successfully created.' }
        format.json { render :show, status: :created, location: @news.metamorphosize }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news/1 or /news/1.json
  def update
    respond_to do |format|
      if @news.update(news_params)
        format.html { redirect_to @news.metamorphosize, notice: 'News was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: @news.metamorphosize }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1 or /news/1.json
  def destroy
    @news.destroy!

    respond_to do |format|
      format.html { redirect_to news_index_path, notice: 'News was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  def list
    @news = News.where(project_id: sessions_current_project_id).page(params[:page]).per(params[:per])
  end

  def types
    types = {
      project: News::PROJECT_TYPES.keys,
      administration: News::ADMINISTRATION_TYPES.keys
    }
   
    render json: types
  end

  private
  def set_news
    @news = News.find(params[:id])
  end

  def news_params
    params.require(:news).permit(:type, :title, :body, :display_start, :display_end, :is_public)
  end
end
