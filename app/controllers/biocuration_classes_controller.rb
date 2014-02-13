class BiocurationClassesController < ApplicationController
  before_action :set_biocuration_class, only: [:show, :edit, :update, :destroy]

  # GET /biocuration_classes
  # GET /biocuration_classes.json
  def index
    @biocuration_classes = BiocurationClass.all
  end

  # GET /biocuration_classes/1
  # GET /biocuration_classes/1.json
  def show
  end

  # GET /biocuration_classes/new
  def new
    @biocuration_class = BiocurationClass.new
  end

  # GET /biocuration_classes/1/edit
  def edit
  end

  # POST /biocuration_classes
  # POST /biocuration_classes.json
  def create
    @biocuration_class = BiocurationClass.new(biocuration_class_params)

    respond_to do |format|
      if @biocuration_class.save
        format.html { redirect_to @biocuration_class, notice: 'Biocuration class was successfully created.' }
        format.json { render action: 'show', status: :created, location: @biocuration_class }
      else
        format.html { render action: 'new' }
        format.json { render json: @biocuration_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biocuration_classes/1
  # PATCH/PUT /biocuration_classes/1.json
  def update
    respond_to do |format|
      if @biocuration_class.update(biocuration_class_params)
        format.html { redirect_to @biocuration_class, notice: 'Biocuration class was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @biocuration_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biocuration_classes/1
  # DELETE /biocuration_classes/1.json
  def destroy
    @biocuration_class.destroy
    respond_to do |format|
      format.html { redirect_to biocuration_classes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_biocuration_class
      @biocuration_class = BiocurationClass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def biocuration_class_params
      params.require(:biocuration_class).permit(:name, :created_by_id, :updated_by_id, :project_id)
    end
end
