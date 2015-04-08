class ImagesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @recent_objects = Image.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
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
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @images = Image.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to images_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to image_path(params[:id])
    end
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

  # GET /images/download
  def download
    send_data Image.generate_download( Image.where(project_id: $project_id) ), type: 'text', filename: "images_#{DateTime.now.to_s}.csv"
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.with_project_id($project_id).find(params[:id])
    @recent_object = @image 
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(:image_file)
  end
end
