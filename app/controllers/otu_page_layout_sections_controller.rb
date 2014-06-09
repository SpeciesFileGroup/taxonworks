class OtuPageLayoutSectionsController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_otu_page_layout_section, only: [:show, :edit, :update, :destroy]

  # GET /otu_page_layout_sections
  # GET /otu_page_layout_sections.json
  def index
    @otu_page_layout_sections = OtuPageLayoutSection.all
  end

  # GET /otu_page_layout_sections/1
  # GET /otu_page_layout_sections/1.json
  def show
  end

  # GET /otu_page_layout_sections/new
  def new
    @otu_page_layout_section = OtuPageLayoutSection.new
  end

  # GET /otu_page_layout_sections/1/edit
  def edit
  end

  # POST /otu_page_layout_sections
  # POST /otu_page_layout_sections.json
  def create
    @otu_page_layout_section = OtuPageLayoutSection.new(otu_page_layout_section_params)

    respond_to do |format|
      if @otu_page_layout_section.save
        format.html { redirect_to @otu_page_layout_section, notice: 'Otu page layout section was successfully created.' }
        format.json { render :show, status: :created, location: @otu_page_layout_section }
      else
        format.html { render :new }
        format.json { render json: @otu_page_layout_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otu_page_layout_sections/1
  # PATCH/PUT /otu_page_layout_sections/1.json
  def update
    respond_to do |format|
      if @otu_page_layout_section.update(otu_page_layout_section_params)
        format.html { redirect_to @otu_page_layout_section, notice: 'Otu page layout section was successfully updated.' }
        format.json { render :show, status: :ok, location: @otu_page_layout_section }
      else
        format.html { render :edit }
        format.json { render json: @otu_page_layout_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otu_page_layout_sections/1
  # DELETE /otu_page_layout_sections/1.json
  def destroy
    @otu_page_layout_section.destroy
    respond_to do |format|
      format.html { redirect_to otu_page_layout_sections_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_otu_page_layout_section
      @otu_page_layout_section = OtuPageLayoutSection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def otu_page_layout_section_params
      params[:otu_page_layout_section]
    end
end
