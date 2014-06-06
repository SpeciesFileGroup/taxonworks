class TaggedSectionKeywordsController < ApplicationController
  before_action :set_tagged_section_keyword, only: [:show, :edit, :update, :destroy]

  # GET /tagged_section_keywords
  # GET /tagged_section_keywords.json
  def index
    @tagged_section_keywords = TaggedSectionKeyword.all
  end

  # GET /tagged_section_keywords/1
  # GET /tagged_section_keywords/1.json
  def show
  end

  # GET /tagged_section_keywords/new
  def new
    @tagged_section_keyword = TaggedSectionKeyword.new
  end

  # GET /tagged_section_keywords/1/edit
  def edit
  end

  # POST /tagged_section_keywords
  # POST /tagged_section_keywords.json
  def create
    @tagged_section_keyword = TaggedSectionKeyword.new(tagged_section_keyword_params)

    respond_to do |format|
      if @tagged_section_keyword.save
        format.html { redirect_to @tagged_section_keyword, notice: 'Tagged section keyword was successfully created.' }
        format.json { render :show, status: :created, location: @tagged_section_keyword }
      else
        format.html { render :new }
        format.json { render json: @tagged_section_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tagged_section_keywords/1
  # PATCH/PUT /tagged_section_keywords/1.json
  def update
    respond_to do |format|
      if @tagged_section_keyword.update(tagged_section_keyword_params)
        format.html { redirect_to @tagged_section_keyword, notice: 'Tagged section keyword was successfully updated.' }
        format.json { render :show, status: :ok, location: @tagged_section_keyword }
      else
        format.html { render :edit }
        format.json { render json: @tagged_section_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tagged_section_keywords/1
  # DELETE /tagged_section_keywords/1.json
  def destroy
    @tagged_section_keyword.destroy
    respond_to do |format|
      format.html { redirect_to tagged_section_keywords_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tagged_section_keyword
      @tagged_section_keyword = TaggedSectionKeyword.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tagged_section_keyword_params
      params[:tagged_section_keyword]
    end
end
