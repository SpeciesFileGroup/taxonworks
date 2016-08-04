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

  def list
    @descriptor = Descriptor.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /descriptors/new
  def new
    @descriptor = Descriptor.new
  end

  # GET /descriptors/1/edit
  def edit
  end

  # POST /descriptors
  # POST /descriptors.json
  def create
    @descriptor = Descriptor.new(descriptor_params)

    respond_to do |format|
      if @descriptor.save
        format.html { redirect_to @descriptor.metamorphosize, notice: 'Descriptor was successfully created.' }
        format.json { render :show, status: :created, location: @descriptor.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @descriptor.metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /descriptors/1
  # PATCH/PUT /descriptors/1.json
  def update
    respond_to do |format|
      if @descriptor.update(descriptor_params)
        format.html { redirect_to @descriptor.metamorphosize, notice: 'Descriptor was successfully updated.' }
        format.json { render :show, status: :ok, location: @descriptor.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @descriptor.metamorphosize.errors, status: :unprocessable_entity }
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

  def autocomplete
    t = "#{params[:term]}%"
    @descriptors = Descriptor.where(project_id: sessions_current_project_id).where('name like ? or short_name like ?', t, t)
    data = @descriptors.collect do |t|
      {id:              t.id,
       label:           t.name, 
       gid: t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html:      t.name 
      }
    end
    render :json => data
  end

  def search
    if params[:id].blank?
      redirect_to descriptors_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to descriptor_path(params[:id])
    end
  end

  private
  
  def set_descriptor
    @descriptor = Descriptor.find(params[:id])
  end

  def descriptor_params
    params.require(:descriptor).permit(:name, :short_name, :type)
  end
end
