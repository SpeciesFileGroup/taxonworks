class FieldOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_field_occurrence, only: %i[ show edit update destroy ]

  after_action -> { set_pagination_headers(:field_occurrences) }, only: [:index, :api_index], if: :json_request?

  # GET /field_occurrences or /field_occurrences.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = FieldOccurrence.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @field_occurrences = ::Queries::FieldOccurrence::Filter.new(params).all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /field_occurrences/1 or /field_occurrences/1.json
  def show
  end

  # GET /field_occurrences/new
  def new
    @field_occurrence = FieldOccurrence.new
  end

  # GET /field_occurrences/1/edit
  def edit
  end

  # POST /field_occurrences or /field_occurrences.json
  def create
    @field_occurrence = FieldOccurrence.new(field_occurrence_params)

    respond_to do |format|
      if @field_occurrence.save
        format.html { redirect_to field_occurrence_url(@field_occurrence), notice: "Field occurrence was successfully created." }
        format.json { render :show, status: :created, location: @field_occurrence }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @field_occurrence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /field_occurrences/1 or /field_occurrences/1.json
  def update
    respond_to do |format|
      if @field_occurrence.update(field_occurrence_params)
        format.html { redirect_to field_occurrence_url(@field_occurrence), notice: "Field occurrence was successfully updated." }
        format.json { render :show, status: :ok, location: @field_occurrence }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @field_occurrence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /field_occurrences/1 or /field_occurrences/1.json
  def destroy
    @field_occurrence.destroy

    respond_to do |format|
      format.html { redirect_to field_occurrences_url, notice: "Field occurrence was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @field_occurrences = ::Queries::FieldOccurrence::Autocomplete.new(
      params[:term],
      project_id: sessions_current_project_id
    ).autocomplete
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_field_occurrence
    @field_occurrence = FieldOccurrence.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def field_occurrence_params
    params.require(:field_occurrence).permit(
      :total, :is_absent,
      :ranged_lot_category_id,
      :collecting_event_id,
      :taxon_determination_id,
      collecting_event_attributes: [],  # needs to be filled out!
      data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :value ],
      tags_attributes: [:id, :_destroy, :keyword_id],
      depictions_attributes: [:id, :_destroy, :svg_clip, :svg_view_box, :position, :caption, :figure_label, :image_id],
      identifiers_attributes: [
        :id,
        :_destroy,
        :identifier,
        :namespace_id,
        :type,
        labels_attributes: [
          :text,
          :type,
          :text_method,
          :total
        ]
      ],
      taxon_determinations_attributes: [
        :id, :_destroy, :otu_id, :year_made, :month_made, :day_made, :position,
        roles_attributes: [:id, :_destroy, :type, :organization_id, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]],
        otu_attributes: [:id, :_destroy, :name, :taxon_name_id]
      ],
      biocuration_classifications_attributes: [
        :id, :_destroy, :biocuration_class_id
      ])
  end
end
