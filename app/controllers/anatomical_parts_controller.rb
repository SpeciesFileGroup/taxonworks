class AnatomicalPartsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_anatomical_part, only: %i[ show edit update destroy ]
  after_action -> { set_pagination_headers(:anatomical_parts) }, only: [:index, :api_index], if: :json_request?

  # GET /anatomical_parts or /anatomical_parts.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = AnatomicalPart
          .where(project_id: sessions_current_project_id)
          .order(updated_at: :desc).limit(10)

        render '/shared/data/all/index'
      end
      format.json do
        @anatomical_parts = ::Queries::AnatomicalPart::Filter.new(params).all
          .page(params[:page])
          .per(params[:per])
          .order('anatomical_parts.name')
      end
    end
  end

  # GET /anatomical_parts/1 or /anatomical_parts/1.json
  def show
  end

  # GET /anatomical_parts/new
  def new
    @anatomical_part = AnatomicalPart.new
  end

  # GET /anatomical_parts/1/edit
  def edit
  end

  # POST /anatomical_parts or /anatomical_parts.json
  def create
    @anatomical_part = AnatomicalPart.new(anatomical_part_params)

    respond_to do |format|
      if @anatomical_part.save
        format.html { redirect_to @anatomical_part, notice: "Anatomical part was successfully created." }
        format.json { render :show, status: :created, location: @anatomical_part }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @anatomical_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /anatomical_parts/1 or /anatomical_parts/1.json
  def update
    respond_to do |format|
      if @anatomical_part.update(anatomical_part_params)
        format.html { redirect_to @anatomical_part, notice: "Anatomical part was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @anatomical_part }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @anatomical_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /anatomical_parts/1 or /anatomical_parts/1.json
  def destroy
    @anatomical_part.destroy!

    respond_to do |format|
      format.html { redirect_to anatomical_parts_path, notice: "Anatomical part was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def list
    @anatomical_parts = AnatomicalPart
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
  end

  def autocomplete
    @anatomical_parts = ::Queries::AnatomicalPart::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id,
    ).autocomplete
  end

  def search
    if params[:id].blank?
      redirect_to(anatomical_part_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to anatomical_part_path(params[:id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_anatomical_part
      @anatomical_part = AnatomicalPart.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def anatomical_part_params
      params.require(:anatomical_part).permit(:name, :uri, :uri_label,
        :is_material, :taxonomic_origin_object_id, :taxonomic_origin_object_type)
    end
end
