class ConveyancesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_conveyance, only: %i[ show edit update destroy ]
  after_action -> { set_pagination_headers(:conveyances) }, only: [:index], if: :json_request?

  # GET /conveyances or /conveyances.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Conveyance.where(
          project_id: sessions_current_project_id
        ).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @conveyances = Queries::Conveyance::Filter.new(params)
          .all
          .where(project_id: sessions_current_project_id)
          .where(Queries::Annotator::polymorphic_params(params, Conveyance)) # TODO: -> configured?
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  def list
    @conveyances = Conveyance.where(project_id: sessions_current_project_id).page(params[:page])
  end

  # GET /conveyances/1 or /conveyances/1.json
  def show
  end

  # GET /conveyances/1/edit
  def edit
  end

  # POST /conveyances or /conveyances.json
  def create
    @conveyance = Conveyance.new(conveyance_params)

    respond_to do |format|
      if @conveyance.save
        format.html { redirect_to @conveyance, notice: 'Conveyance was successfully created.' }
        format.json { render :show, status: :created, location: @conveyance }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @conveyance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conveyances/1 or /conveyances/1.json
  def update
    respond_to do |format|
      if @conveyance.update(conveyance_params)
        format.html { redirect_to @conveyance, notice: 'Conveyance was successfully updated.' }
        format.json { render :show, status: :ok, location: @conveyance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @conveyance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conveyances/1 or /conveyances/1.json
  def destroy
    @conveyance.destroy!

    respond_to do |format|
      format.html { redirect_to conveyances_path, status: :see_other, notice: 'Conveyance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_conveyance
    @conveyance = Conveyance.find(params[:id])
  end

  def conveyance_params
    params.require(:conveyance).permit(
      :sound_id, 
      :conveyance_object_id, 
      :conveyance_object_type,
      :position,
      sound_attributes: [
        :sound_file,
        :name
      ]
    )
  end
end
