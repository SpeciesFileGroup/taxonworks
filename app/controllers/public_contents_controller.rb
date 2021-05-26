class PublicContentsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_public_content, only: [:update, :destroy]

  # POST /public_contents
  # POST /public_contents.json
  def create
    @public_content = PublicContent.new(public_content_params)

    respond_to do |format|
      if @public_content.save
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Public content was successfully created.')}
        format.json { render json: @public_content, status: :created, location: @public_content }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Public content was NOT successfully created.')}
        format.json { render json: @public_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /public_contents/1
  # PATCH/PUT /public_contents/1.json
  def update
    respond_to do |format|
      if @public_content.update(public_content_params)
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Public content was successfully updated.')}
        format.json { render @public_content, status: :ok, location: @public_content }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Public content was NOT successfully updated.')}
        format.json { render json: @public_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_contents/1
  # DELETE /public_contents/1.json
  def destroy
    @public_content.destroy
    respond_to do |format|
      format.html { destroy_redirect @public_content, notice: 'Public content was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_public_content
      @public_content = PublicContent.with_project_id(sessions_current_project_id).find(params[:id])
      @recent_object = @public_content 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def public_content_params
      params.require(:public_content).permit(:otu_id, :topic_id, :content_id, :text)
    end
end
