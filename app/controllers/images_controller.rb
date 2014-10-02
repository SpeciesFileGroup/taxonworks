class ImagesController < ApplicationController
  include DataControllerConfiguration

  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @recent_objects = Image.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @images = Image.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def autocomplete
    @images = Image.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) # in model

    data = @images.collect do |t|
      {id:              t.id,
       label:           ImagesHelper.image_tag(t), # in helper
       response_values: {
           params[:method] => t.id
       },
       label_html:      ImagesHelper.image_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:user_file_name, :height, :width, :image_file_fingerprint, :created_by_id, :project_id, :image_file_file_name, :image_file_content_type, :image_file_file_size, :image_file_updated_at, :updated_by_id)
    end
end
