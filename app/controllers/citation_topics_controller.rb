class CitationTopicsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_citation_topic, only: [:update, :destroy]

  # POST /citation_topics
  # POST /citation_topics.json
  def create
    @citation_topic = CitationTopic.new(citation_topic_params)

    respond_to do |format|
      if @citation_topic.save
        format.html { redirect_to :back, notice: 'Citation topic was successfully created.' }
        format.json { render json: @citation_topic, status: :created, location: @citation_topic }
      else
        format.html { redirect_to :back, notice: 'Citation topic was NOT successfully created.' }
        format.json { render json: @citation_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /citation_topics/1
  # PATCH/PUT /citation_topics/1.json
  def update
    respond_to do |format|
      if @citation_topic.update(citation_topic_params)
        format.html { redirect_to :back, notice: 'Citation topic was successfully updated.' }
        format.json { render json: @citation_topic, status: :ok, location: @citation_topic }
      else
        format.html { redirect_to :back, notice: 'Citation topic was NOT successfully updated.' }
        format.json { render json: @citation_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /citation_topics/1
  # DELETE /citation_topics/1.json
  def destroy
    @citation_topic.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Citation topic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_citation_topic
      @citation_topic = CitationTopic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def citation_topic_params
      params.require(:citation_topic).permit(:citation_id, :topic_id)
    end
end
