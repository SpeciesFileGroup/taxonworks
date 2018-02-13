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

  # TODO: deprecate!
  def search
    if params[:id].blank?
      redirect_to people_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to person_path(params[:id])
    end
  end

  def autocomplete
    @people = people
  end

  # TODO: Deprecate for autocomplete with params
  # this is used only in specific forms where you want to find people who are ALREADY taxon name authors
  def taxon_name_author_autocomplete
    @authors = Person.joins(:roles).where(roles: {type: 'TaxonNameAuthor', project_id: sessions_current_project_id}).find_for_autocomplete(params.permit(:term)).distinct.order('people.cached').limit(50)
    data = @authors.collect do |a|
      {id: a.id,
       label: a.name,
       response_values: {
           params[:method] => a.id
       },
       label_html: a.cached
      }
    end
    render json: data
  end

  # GET /people/download
  def download
    send_data Download.generate_csv(Person.all), type: 'text', filename: "people_#{DateTime.now}.csv"
  end

  def roles
  end

  # GET /people/role_types.json
  def role_types
    render json: ROLES
  end

  # GET /person/:id/details
  def details
    @person = Person.includes(:roles).find(params[:id])
    render partial: '/people/picker_details', locals: {person:  @person}
  end

  private

  def people
    t = params.require(:term)
    Person.select("people.*, length(cached) c").where('cached ILIKE ? OR cached ILIKE ? OR cached = ?', "#{t}%", "%#{t}%", t).distinct.order('c ASC', 'cached ASC').limit(50)
  end

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
