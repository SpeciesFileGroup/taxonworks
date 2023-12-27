class FieldOccurrencesController < ApplicationController
  before_action :set_field_occurrence, only: %i[ show edit update destroy ]

  # GET /field_occurrences or /field_occurrences.json
  def index
    @field_occurrences = FieldOccurrence.all
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_field_occurrence
      @field_occurrence = FieldOccurrence.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def field_occurrence_params
      params.require(:field_occurrence).permit(:total, :collecting_event_id_id, :is_absent)
    end
end
