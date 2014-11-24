class IdentifiersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_identifier, only: [:update, :destroy]

  def new
    @identifier = Identifier.new(identifier_params)
  end

  # GET /identifiers
  # GET /identifiers.json
  def index
    @identifiers = Identifier.all
  end

  # POST /identifiers
  # POST /identifiers.json
  def create

    @identifier = Identifier.new(identifier_params)
    respond_to do |format|
      if @identifier.save
        format.html { redirect_to :back, notice: 'Identifier was successfully created.' }
        format.json { render json: @identifier, status: :created, location: @identifier.becomes(Identifier) }
      else
        format.html { redirect_to :back, notice: 'Identifier was NOT successfully created.' }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identifiers/1
  # PATCH/PUT /identifiers/1.json
  def update
    respond_to do |format|
      if @identifier.update(identifier_params)
        format.html { redirect_to :back, notice: 'Identifier was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Identifier was NOT successfully updated.' }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identifiers/1
  # DELETE /identifiers/1.json
  def destroy
    @identifier.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @identifiers = Identifier.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = @identifiers.collect do |t|
      str = render_to_string(
          partial: 'tag',
          locals: {identifier: t})
      {id: t.id,
       label: str,
       response_values: {
           params[:method] => t.id
       },
       label_html: str
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_identifier
    @identifier = Identifier.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def identifier_params
    params.require(:identifier).permit(:identified_object_id, :identified_object_type, :identifier, :type, :namespace_id)
  end
end
