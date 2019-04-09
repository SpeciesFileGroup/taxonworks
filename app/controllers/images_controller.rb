class ImagesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @recent_objects = Image.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
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
    if @image.destroy
      respond_to do |format|
        format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to images_url, notice: @image.errors.full_messages.join('. ') }
        format.json { head :no_content, status: :im_used }
      end
    end
  end

  def list
    @images = Image.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to images_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to image_path(params[:id])
    end
  end

  def autocomplete
    @images = Queries::Image::Autocomplete.new(params[:term], project_id: sessions_current_project_id).autocomplete
  end

  # GET /images/download
  def download
    send_data(Download.generate_csv(Image.where(project_id: sessions_current_project_id)),
              type: 'text',
              filename: "images_#{DateTime.now}.csv")
  end

  # GET /images/:id/extract/:x/:y/:height/:width
  def extract
    send_data Image.cropped_blob(params), type: 'image/jpg', disposition: 'inline'
  end

  # GET /images/:id/extract/:x/:y/:height/:width/:new_height/:new_width
  def scale
    send_data Image.resized_blob(params), type: 'image/jpg', disposition: 'inline'
  end

  # GET 'images/:id/scale_to_box/:x/:y/:width/:height/:box_width/:box_height'
  def scale_to_box
    send_data Image.scaled_to_box_blob(params), type: 'image/jpg', disposition: 'inline'
  end

  # GET /images/:id/ocr/:x/:y/:height/:width
  def ocr
    tempfile = Tempfile.new(['ocr', '.jpg'], "#{Rails.root}/public/images/tmp", encoding: 'utf-8')
    tempfile.write(Image.cropped_blob(params).force_encoding('utf-8'))
    tempfile.rewind

    render json: {text: RTesseract.new(tempfile.path).to_s&.strip}
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @image
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(
      :image_file,
      citations_attributes: [:id, :is_original, :_destroy, :source_id, :pages, :citation_object_id, :citation_object_type]
    )
  end
end
