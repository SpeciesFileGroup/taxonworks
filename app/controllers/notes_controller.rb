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
    @recent_objects = Note.where(project_id: $project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(note_params)

    respond_to do |format|
      if @note.save
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
        format.html { redirect_to @note.note_object.metamorphosize, notice: 'Note was successfully created.' }
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

  def list
    @notes = Note.where(project_id: $project_id).order(:note_object_type).page(params[:page])
  end

  # GET /notes/search
  def search
    if params[:id].blank?
      redirect_to note_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to note_path(params[:id])
    end
  end

  def autocomplete
    @notes = Note.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = @notes.collect do |t|
      str = render_to_string(partial: 'tag', locals: {note: t})
      {id: t.id,
       label: str,
       response_values: {
           params[:method] => t.id},
       label_html: str
      }
    end

    render :json => data
  end

  # GET /notes/download
  def download
    send_data Note.generate_download(Note.where(project_id: $project_id)), type: 'text', filename: "notes_#{DateTime.now.to_s}.csv"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_note
    @note = Note.with_project_id($project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def note_params
    params.require(:note).permit(:text, :note_object_id, :note_object_type, :note_object_attribute)
  end
end
