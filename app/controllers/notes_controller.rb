class NotesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_note, only: [:update, :destroy]

  def new
    @note = Note.new(note_params)
  end

  def edit
    @note = Note.find_by_id(params[:id]).metamorphosize
  end

  # GET /notes
  # GET /notes.json
  def index
    @notes = Note.all
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(note_params)

    respond_to do |format|
      if @note.save
        # format.html { redirect_to :back, notice: 'Note was successfully created.' }
        # format.json { render json: @note, status: :created, location: @note }
        # copies from alternate_values:
        format.html { redirect_to @note.note_object.metamorphosize, notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created, location: @note }
      else
        format.html { redirect_to :back, notice: 'Note was NOT successfully created.' }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        # format.html { redirect_to :back, notice: 'Note was successfully updated.' }
        # copied from alternate_values:
        format.html { redirect_to @note.note_object.metamorphosize, notice: 'Note was successfully created.' }
        format.html { redirect_to :back, notice: 'Note was successfully updated.' }
        # format.json { head :no_content }
        format.json { render json: @note, status: :created, location: @note }
      else
        format.html { redirect_to :back, notice: 'Note was NOT successfully updated.' }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def note_params
      params.require(:note).permit(:text, :note_object_id, :note_object_type, :note_object_attribute, :created_by_id, :updated_by_id, :project_id)
    end
end
