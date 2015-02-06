class PreparationTypesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_administrator_sign_in, only: [:edit, :update, :destroy, :index]
  before_action :set_preparation_type, only: [:show, :edit, :update, :destroy]

  # GET /preparation_types
  # GET /preparation_types.json
  def index
    @preparation_types = PreparationType.all
    @recent_objects = PreparationType.order(updated_at: :desc).limit(10)
  end

  # GET /preparation_types/1
  # GET /preparation_types/1.json
  def show
  end

  # GET /preparation_types/new
  def new
    @preparation_type = PreparationType.new
  end

  # GET /preparation_types/1/edit
  def edit
  end

  # POST /preparation_types
  # POST /preparation_types.json
  def create
    @preparation_type = PreparationType.new(preparation_type_params)

    respond_to do |format|
      if @preparation_type.save
        format.html { redirect_to @preparation_type, notice: "Preparation type '#{@preparation_type.name}' was successfully created." }
        format.json { render action: 'show', status: :created, location: @preparation_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @preparation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /preparation_types/1
  # PATCH/PUT /preparation_types/1.json
  def update
    respond_to do |format|
      if @preparation_type.update(preparation_type_params)
        format.html { redirect_to @preparation_type, notice: 'Preparation type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @preparation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /preparation_types/1
  # DELETE /preparation_types/1.json
  def destroy
    @preparation_type.destroy
    respond_to do |format|
      format.html { redirect_to preparation_types_url }
      format.json { head :no_content }
    end
  end

  def list
    @preparation_types = PreparationType.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id]
      redirect_to preparation_type_path(params[:id])
    else
      redirect_to preparation_type_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  # def autocomplete
  #   @preparation_types = PreparationType.find_for_autocomplete(params)
  #
  #   data = @preparation_types.collect do |t|
  #     {id: t.id,
  #      label: PreparationTypesHelper.preparation_type_tag(t),
  #      response_values: {
  #          params[:method] => t.id
  #      },
  #      label_html: PreparationTypesHelper.preparation_type_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
  #     }
  #   end
  #
  #   render :json => data
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_preparation_type
    @preparation_type = PreparationType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def preparation_type_params
    params.require(:preparation_type).permit(:name, :definition, :created_by_id, :updated_by_id)
  end
end
