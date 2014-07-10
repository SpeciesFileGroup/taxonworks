class OtusController < ApplicationController
  include DataControllerConfiguration

  before_action :set_otu, only: [:show, :edit, :update, :destroy]

  # GET /otus
  # GET /otus.json
  def index
    @recent_objects = Otu.recent_from_project_id($project_id).limit(5)
  end

  # GET /otus/1
  # GET /otus/1.json
  def show
  end

  # GET /otus/new
  def new
    @otu = Otu.new
  end

  # GET /otus/1/edit
  def edit
  end

  def list
    @otus = Otu.all
  end

  # POST /otus
  # POST /otus.json
  def create
    @otu = Otu.new(otu_params)

    respond_to do |format|
      if @otu.save
        format.html { redirect_to @otu, notice: 'Otu was successfully created.' }
        format.json { render action: 'show', status: :created, location: @otu }
      else
        format.html { render action: 'new' }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otus/1
  # PATCH/PUT /otus/1.json
  def update
    respond_to do |format|
      if @otu.update(otu_params)
        format.html { redirect_to @otu, notice: 'Otu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otus/1
  # DELETE /otus/1.json
  def destroy
    @otu.destroy
    respond_to do |format|
      format.html { redirect_to otus_url }
      format.json { head :no_content }
    end
  end

  def search
    redirect_to otu_path(params[:otu][:id])
  end

 def auto_complete_for_otus
    @otus = Otu.where('name LIKE ?', "#{params[:term]}%") # find_for_auto_complete(conditions, table_name)

    data = @otus.collect do |t|
      {id: t.id,
       label: OtusHelper.otu_tag(t), 
       response_values: {
         params[:method] => t.id  
       },
       label_html: OtusHelper.otu_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data 
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_otu
      @otu = Otu.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def otu_params
      params.require(:otu).permit(:name)
    end
end
