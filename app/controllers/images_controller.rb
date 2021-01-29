class ImagesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  after_action -> { set_pagination_headers(:images) }, only: [:index, :api_index], if: :json_request?

  before_action :set_image, only: [:show, :edit, :update, :destroy, :rotate]

  # GET /images
  # GET /images.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Image.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @images = Queries::Image::Filter.new(filter_params).all
          .where(project_id: sessions_current_project_id)
          .all.page(params[:page]).per(params[:per] || 50)
      }
    end
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

  # TODO: remove for /images.json
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
    send_data(Export::Download.generate_csv(Image.where(project_id: sessions_current_project_id)),
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

  # !! This is a kludge until we get active storage working
  # PATCH /images/123/rotate
  def rotate
    begin
      @image.rotate = params.require(:image).require(:rotate)
      @image.image_file.reprocess!
      flash[:notice] = 'Image rotated.'
    rescue ActionController::ParameterMissing
      flash[:notice] ='Select a rotation option.'
    end
    render :show
  end

  # GET /images/select_options?target=TaxonDetermination
  def select_options
    @images = Image.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:target))
  end

  private

  def filter_params
    params.permit(
      :taxon_name_id,
      :ancestor_id_target,
      :otu_id,
      :collection_object_id,
      :image_id,
      :biocuration_class_id,
      :sled_image_id,
      :depiction,
      :user_id, # user
      :user_target,
      :user_date_start,
      :user_date_end,
      :identifier,
      :identifier_end,
      :identifier_exact,
      :identifier_start,
      keyword_ids: [],
      taxon_name_id: [],
      sled_image_id: [],
      biocuration_class_id: [],
      image_id: [],
      collection_object_id: [],
      otu_id: []
    ).to_h.symbolize_keys.merge(project_id: sessions_current_project_id)
  end


  def set_image
    @image = Image.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @image
  end

  def image_params
    params.require(:image).permit(
      :image_file, :rotate,
      :pixels_to_centimeter,
      citations_attributes: [:id, :is_original, :_destroy, :source_id, :pages, :citation_object_id, :citation_object_type],
      sled_image_attributes: [:id, :_destroy, :metadata, :object_layout]
    )
  end
end
