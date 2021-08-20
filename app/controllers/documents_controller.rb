class DocumentsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    @recent_objects = Document.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
        format.json { render action: 'show', status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @documents = Document.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  def search
    if params[:id].blank?
      redirect_to documents_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to document_path(params[:id])
    end
  end

  def autocomplete
    @documents = Queries::Document::Autocomplete.new(params[:term], project_id: params[:project_id]).all
  end

  private

  def set_document
    @document = Document.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def document_params
    params.require(:document).permit(:document_file, :initialize_start_page, :is_public)  
  end
end
