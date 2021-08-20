class SequencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  
  before_action :set_sequence, only: [:show, :edit, :update, :destroy]

  # GET /sequences
  # GET /sequences.json
  def index
    @recent_objects = Sequence.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
  end

  # GET /sequences/new
  def new
    @sequence = Sequence.new
  end

  # GET /sequences/1/edit
  def edit
  end

  def list
    @sequences = Sequence.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = Sequence.new(sequence_params)

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to @sequence, notice: 'Sequence was successfully created.' }
        format.json { render :show, status: :created, location: @sequence }
      else
        format.html { render :new }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sequences/1
  # PATCH/PUT /sequences/1.json
  def update
    respond_to do |format|
      if @sequence.update(sequence_params)
        format.html { redirect_to @sequence, notice: 'Sequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @sequence }
      else
        format.html { render :edit }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sequences/1
  # DELETE /sequences/1.json
  def destroy
    @sequence.destroy
    respond_to do |format|
      format.html { redirect_to sequences_url, notice: 'Sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to sequences_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to sequence_path(params[:id])
    end
  end

  def autocomplete
    t = "#{params[:term]}%"
    @sequences = Sequence.where(project_id: sessions_current_project_id).where('sequence ILIKE ? OR name ILIKE ?', t, t)
    data = @sequences.collect do |t|
      l = [t.name, t.sequence[0..10]].compact.join(': ')
      {id: t.id,
       label: l, 
       gid: t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html: l      }
    end

    render json: data
  end

  def batch_load
  end

  def preview_genbank_batch_file_load 
    if params[:files] 
      @result = BatchFileLoad::Import::Sequences::GenbankInterpreter.new(**batch_params)
      digest_cookie(params[:files][0].tempfile, :batch_file_load_genbank_sequences_md5)
      render 'sequences/batch_file_load/genbank/preview'
    else
      flash[:notice] = 'No file(s) provided!'
      redirect_to action: :batch_load 
    end
  end

  def create_genbank_batch_file_load
    if params[:files] && digested_cookie_exists?(params[:files][0].tempfile, :batch_file_load_genbank_sequences_md5)
      @result = BatchFileLoad::Import::Sequences::GenbankInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully processed #{@result.total_files_processed} file(s), #{@result.total_records_created} sequences were created."
        render 'sequences/batch_file_load/genbank/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def preview_genbank_batch_load 
    if params[:file] 
      @result = BatchLoad::Import::Sequences::GenbankInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :Genbank_sequences_md5)
      render 'sequences/batch_load/genbank/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load 
    end
  end

  def create_genbank_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Genbank_sequences_md5)
      @result = BatchLoad::Import::Sequences::GenbankInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} sequences were created."
        render 'sequences/batch_load/genbank/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def preview_primers_batch_load 
    if params[:file] 
      @result = BatchLoad::Import::Sequences::PrimersInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :Primers_sequences_md5)
      render 'sequences/batch_load/primers/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load 
    end
  end

  def create_primers_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Primers_sequences_md5)
      @result = BatchLoad::Import::Sequences::PrimersInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} sequences were created."
        render 'sequences/batch_load/primers/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def select_options
    @sequences = Sequence.select_optimized(sessions_current_user_id, sessions_current_project_id, params[:target])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequence
      @sequence = Sequence.where(project_id: sessions_current_project_id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequence_params
      params.require(:sequence).permit(:name, :sequence, :sequence_type, :created_by_id, :updated_by_id, :project_id)
    end

    def batch_params
      params.permit(:namespace, :file, :import_level, files: []).merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).to_h.symbolize_keys
    end
end
