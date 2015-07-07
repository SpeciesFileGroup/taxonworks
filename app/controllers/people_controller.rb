class PeopleController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_person, only: [:show, :edit, :update, :destroy, :roles]

  # GET /people
  # GET /people.json
  def index
    @people = Person.all.includes(:creator, :updater)
    @recent_objects = Person.order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /people/1
  # GET /people/1.json
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person.metamorphosize, notice: "Person '#{@person.name}' was successfully created." }
        format.json { render action: 'show', status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person.metamorphosize, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def list
    @people =  Person.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to people_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to person_path(params[:id])
    end
  end

  def autocomplete
    @people = Person.find_for_autocomplete(params)
    data = @people.collect do |t|
      {id:              t.id,
       label:           t.name,
       response_values: {
           params[:method] => t.id
       },
       label_html:     t.name 
      }
    end

    render :json => data
  end

  # GET /people/download
  def download
    send_data Person.generate_download( Person.all ), type: 'text', filename: "people_#{DateTime.now.to_s}.csv"
  end

  def roles

  end

  def lookup_person
    @people = Person.find_for_autocomplete(params)
    render :json => @people.collect{|p|
      {
        label: p.bibtex_name,
        object_id: p.id}
    }
  end

  # GET /person/:id/details
  def details 
    @person = Person.includes(:roles).find(params[:id])
    render partial: '/people/picker_details', locals: {person:  @person} 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
      @recent_object = @person
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:type, :last_name, :first_name, :suffix, :prefix)
    end
end
