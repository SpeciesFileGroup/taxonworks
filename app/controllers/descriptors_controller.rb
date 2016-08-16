class DescriptorsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_descriptor, only: [:show, :edit, :update, :destroy]

  # GET /descriptors
  # GET /descriptors.json
  def index
    @recent_objects = Descriptor.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /descriptors/1
  # GET /descriptors/1.json
  def show
  end

  # GET /descriptors/new
  def new
    @descriptor = Descriptor.new
  end

  # GET /descriptors/1/edit
  def edit
  end

  def list
    @descriptors = Descriptor.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /descriptors
  # POST /descriptors.json
  def create
    @descriptor = Descriptor.new(descriptor_params)

    respond_to do |format|
      if @descriptor.save
        format.html { redirect_to @descriptor, notice: 'Descriptor was successfully created.' }
        format.json { render :show, status: :created, location: @descriptor }
      else
        format.html { render :new }
        format.json { render json: @descriptor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /descriptors/1
  # PATCH/PUT /descriptors/1.json
  def update
    respond_to do |format|
      if @descriptor.update(descriptor_params)
        format.html { redirect_to @descriptor, notice: 'Descriptor was successfully updated.' }
        format.json { render :show, status: :ok, location: @descriptor }
      else
        format.html { render :edit }
        format.json { render json: @descriptor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /descriptors/1
  # DELETE /descriptors/1.json
  def destroy
    @descriptor.destroy
    respond_to do |format|
      format.html { redirect_to descriptors_url, notice: 'Descriptor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to descriptors_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to descriptor_path(params[:id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_descriptor
      @descriptor = Descriptor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def descriptor_params
      params.require(:descriptor).permit(:descriptor_id, :created_by_id, :updated_by_id, :project_id)
    end
end
