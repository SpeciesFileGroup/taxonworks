class NotesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  include ShallowPolymorphic

  before_action :set_note, only: [:update, :destroy, :api_show]
  after_action -> { set_pagination_headers(:notes) }, only: [:index, :api_index ], if: :json_request?

  # GET /notes
  # GET /notes.json
  # GET /<model>/:id/notes.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Note.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @notes = Queries::Note::Filter.new(filter_params)
          .all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  def new
    @note = Note.new(note_params)
  end

  def edit
    @note = Note.find_by_id(params[:id]).metamorphosize
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(note_params)

    respond_to do |format|
      if @note.save
        format.html { redirect_to url_for(@note.note_object.metamorphosize),
                      notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created, location: @note }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path),
                                    notice: 'Note was NOT successfully created.') }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to url_for(@note.note_object.metamorphosize),
                      notice: 'Note was successfully created.' }
        format.json { render action: 'show', status: :created, location: @note }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path),
                                    notice:            'Note was NOT successfully updated.') }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      # TODO: probably needs to be changed
      format.html { destroy_redirect @note, notice: 'Note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @notes = Note.where(project_id: sessions_current_project_id).order(:note_object_type).page(params[:page])
  end

  # GET /notes/search
  def search
    if params[:id].blank?
      redirect_to note_path, notice: 'You must select an item from the list with a click or' \
        ' tab press before clicking show.'
    else
      if @note = Note.find(params[:id])
        redirect_to url_for(@note.note_object.metamorphosize)
      else
        redirect_to note_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
      end
    end
  end

  def autocomplete
    render json: {} and return if params[:term].blank?
    @notes = Queries::Note::Autocomplete.new(params.require(:term), project_id: sessions_current_project_id).autocomplete
  end

  # GET /notes/download
  def download
    send_data Export::Download.generate_csv(Note.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "notes_#{DateTime.now}.csv"
  end

  # GET /api/v1/notes
  def api_index
    @notes = Queries::Note::Filter.new(api_params).all
      .order('notes.id')
      .page(params[:page])
      .per(params[:per])
    render '/notes/api/v1/index'
  end

  # GET /api/v1/notes/:id
  def api_show
    render '/notes/api/v1/show'
  end

  private

  def filter_params
    params.permit(
      :text,
      :note_object_id,
      :note_object_type,
      :object_global_id,
      note_object_id: [],
      note_object_type: [],
    ).to_h
      .merge(shallow_object_global_param)
      .merge(project_id: sessions_current_project_id)
  end

  def api_params
    params.permit(
      :text,
      :note_object_id,
      :note_object_type,
      :object_global_id,
      note_object_id: [],
      note_object_type: [],
    ).to_h
      .merge(shallow_object_global_param)
      .merge(project_id: sessions_current_project_id)
  end

  def set_note
    @note = Note.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def note_params
    params.require(:note).permit(
      :text, :note_object_id, :note_object_type,
      :note_object_attribute, :annotated_global_entity)
  end

end
