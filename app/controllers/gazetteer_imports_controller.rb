class GazetteerImportsController < ApplicationController
  before_action :set_gazetteer_import, only: %i[ show edit update destroy ]

  # GET /gazetteer_imports or /gazetteer_imports.json
  def index
    @gazetteer_imports = GazetteerImport.all
  end

  # GET /gazetteer_imports/1 or /gazetteer_imports/1.json
  def show
  end

  # GET /gazetteer_imports/new
  def new
    @gazetteer_import = GazetteerImport.new
  end

  # GET /gazetteer_imports/1/edit
  def edit
  end

  # POST /gazetteer_imports or /gazetteer_imports.json
  def create
    @gazetteer_import = GazetteerImport.new(gazetteer_import_params)

    respond_to do |format|
      if @gazetteer_import.save
        format.html { redirect_to gazetteer_import_url(@gazetteer_import), notice: "Gazetteer import was successfully created." }
        format.json { render :show, status: :created, location: @gazetteer_import }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gazetteer_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gazetteer_imports/1 or /gazetteer_imports/1.json
  def update
    respond_to do |format|
      if @gazetteer_import.update(gazetteer_import_params)
        format.html { redirect_to gazetteer_import_url(@gazetteer_import), notice: "Gazetteer import was successfully updated." }
        format.json { render :show, status: :ok, location: @gazetteer_import }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gazetteer_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gazetteer_imports/1 or /gazetteer_imports/1.json
  def destroy
    @gazetteer_import.destroy!

    respond_to do |format|
      format.html { redirect_to gazetteer_imports_url, notice: "Gazetteer import was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /gazetteer_imports/all.json
  def all
    @import_jobs = GazetteerImport
      .joins('JOIN users ON gazetteer_imports.created_by_id = users.id')
      .select('gazetteer_imports.*, users.name AS submitted_by')
      .where(project_id: sessions_current_project_id)
      .order(created_at: :desc)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gazetteer_import
      @gazetteer_import = GazetteerImport.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def gazetteer_import_params
      params.fetch(:gazetteer_import, {})
    end
end
