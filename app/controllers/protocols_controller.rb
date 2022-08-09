class ProtocolsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_protocol, only: [:show, :edit, :update, :destroy]

  # GET /protocols
  # GET /protocols.json
  def index
    @recent_objects = Protocol.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    respond_to do |format|
      format.html {
        render '/shared/data/all/index'
      }
      format.json {
        @protocols = Protocol.where(project_id: sessions_current_project_id).order(:name).all
      }
    end
  end

  # GET /protocols/1
  # GET /protocols/1.json
  def show
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
  end

  # GET /protocols/1/edit
  def edit
  end

  def list
    @protocols = Protocol.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /protocols
  # POST /protocols.json
  def create
    @protocol = Protocol.new(protocol_params)

    respond_to do |format|
      if @protocol.save
        format.html { redirect_to @protocol, notice: 'Protocol was successfully created.' }
        format.json { render :show, status: :created, location: @protocol }
      else
        format.html { render :new }
        format.json { render json: @protocol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /protocols/1
  # PATCH/PUT /protocols/1.jsoned by Vsauce
  def update
    respond_to do |format|
      if @protocol.update(protocol_params)
        format.html { redirect_to @protocol, notice: 'Protocol was successfully updated.' }
        format.json { render :show, status: :ok, location: @protocol }
      else
        format.html { render :edit }
        format.json { render json: @protocol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protocols/1
  # DELETE /protocols/1.json
  def destroy
    @protocol.destroy
    respond_to do |format|
      format.html { redirect_to protocols_url, notice: 'Protocol was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to protocols_path, notice: 'You must select an item from the list with a click or tab press before clicking show'
    else
      redirect_to protocol_path(params[:id])
    end
  end

  def autocomplete
    @protocols = Protocol.where(project_id: sessions_current_project_id).where('name ILIKE ?', "#{params[:term]}%").order(:name)

    data = @protocols.collect do |t|
      {id: t.id,
       label: t.name,
       gid: t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html: t.name
      }
    end

    render json: data
  end


  def select_options
    @protocols = Protocol.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:klass))
  end

  private

  def set_protocol
    @protocol = Protocol.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def protocol_params
    params.require(:protocol).permit(:name, :short_name, :description)
  end
end
