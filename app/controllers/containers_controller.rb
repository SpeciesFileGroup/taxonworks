class ContainersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_container, only: [:update, :destroy]

  # POST /containers
  # POST /containers.json
  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to :back, notice: 'Container was successfully created.' }
        format.json { render json: @container, status: :created, location: @container }
      else
        format.html { redirect_to :back, notice: 'Container was NOT successfully created.' }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to :back, notice: 'Container was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Container was NOT successfully updated.' }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    @container.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Container was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.with_project_id($project_id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit(:parent_id, :depth, :type, :otu_id, :name, :disposition)
    end
end
