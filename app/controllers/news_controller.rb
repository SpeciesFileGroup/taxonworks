class NewsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_news, only: %i[ show edit update destroy ]

  # GET /news or /news.json
  def index
    respond_to do |format|
      format.html do
        # TODO: unexpired
        @recent_objects = News.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @news = News.where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
          .order(:display_start)
      }
    end
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
        format.html { redirect_to @news.becomes(@news.class.base_class), notice: "News was successfully created." }
        format.json { render :show, status: :created, location: @news }
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
        format.html { redirect_to @news.metamorphosize, notice: "News was successfully updated.", status: :see_other }
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
      format.html { redirect_to news_index_path, notice: "News was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
  def set_news
    @news = News.find(params[:id])
  end

  def news_params
    params.require(:news).permit(:type, :title, :body, :display_start, :display_end) # TODO: admin news considerations
  end
end
