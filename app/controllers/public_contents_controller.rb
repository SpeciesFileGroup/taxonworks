class PublicContentsController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_public_content, only: [:show, :edit, :update, :destroy]

  # GET /public_contents
  # GET /public_contents.json
  def index
    @public_contents = PublicContent.all
  end

  # GET /public_contents/1
  # GET /public_contents/1.json
  def show
  end

  # GET /public_contents/new
  def new
    @public_content = PublicContent.new
  end

  # GET /public_contents/1/edit
  def edit
  end

  # POST /public_contents
  # POST /public_contents.json
  def create
    @public_content = PublicContent.new(public_content_params)

    respond_to do |format|
      if @public_content.save
        format.html { redirect_to @public_content, notice: 'Public content was successfully created.' }
        format.json { render :show, status: :created, location: @public_content }
      else
        format.html { render :new }
        format.json { render json: @public_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /public_contents/1
  # PATCH/PUT /public_contents/1.json
  def update
    respond_to do |format|
      if @public_content.update(public_content_params)
        format.html { redirect_to @public_content, notice: 'Public content was successfully updated.' }
        format.json { render :show, status: :ok, location: @public_content }
      else
        format.html { render :edit }
        format.json { render json: @public_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_contents/1
  # DELETE /public_contents/1.json
  def destroy
    @public_content.destroy
    respond_to do |format|
      format.html { redirect_to public_contents_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_public_content
      @public_content = PublicContent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def public_content_params
      params[:public_content]
    end
end
