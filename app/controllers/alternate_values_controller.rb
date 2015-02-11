class AlternateValuesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_alternate_value, only: [:update, :destroy] # :edit removed from this list

  def new
    @alternate_value = AlternateValue.new(alternate_value_params)
  end

  def edit
    @alternate_value = AlternateValue.find_by_id(params[:id]).metamorphosize
  end

  # GET /alternate_values
  # GET /alternate_values.json
  def index
    @recent_objects = AlternateValue.where(project_id: $project_id).order(updated_at: :desc).limit(10)
  end

  # POST /alternate_values
  # POST /alternate_values.json
  def create
    @alternate_value = AlternateValue.new(alternate_value_params)
    respond_to do |format|
      if @alternate_value.save
        format.html { redirect_to @alternate_value.alternate_value_object.metamorphosize, notice: 'Alternate value was successfully created.' }
        format.json { render json: @alternate_value, status: :created, location: @alternate_value }
      else
        format.html { render 'new', notice: 'Alternate value was NOT successfully created.' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alternate_values/1
  # PATCH/PUT /alternate_values/1.json
  def update
    respond_to do |format|
      if @alternate_value.update(alternate_value_params)
        format.html { redirect_to @alternate_value.alternate_value_object.metamorphosize, notice: 'Alternate value was successfully updated.' }
        format.json { render json: @alternate_value, status: :created, location: @alternate_value }
      else
        format.html { redirect_to :back, notice: 'Alternate value was NOT successfully updated.' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alternate_values/1
  # DELETE /alternate_values/1.json
  def destroy
    @alternate_value.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Alternate value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @alternate_values = AlternateValue.where(project_id: $project_id).order(:alternate_value_object_type).page(params[:page])
  end

  # GET /alternate_values/search
  def search
    if params[:id]
      redirect_to alternate_value_path(params[:id])
    else
      redirect_to alternate_value_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def autocomplete
    @alternate_values = AlternateValue.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = @alternate_values.collect do |t|
      str = render_to_string(partial: 'tag', locals: {alternate_value: t})
      {id: t.id,
       label: str,
       response_values: {
           params[:method] => t.id},
       label_html: str
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_alternate_value
    @alternate_value = AlternateValue.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def alternate_value_params
    params.require(:alternate_value).permit(:value, :type, :language_id, :alternate_value_object_type, :alternate_value_object_id, :alternate_value_object_attribute)
  end

  def breakout_types(collection)
    collection
  end
end
