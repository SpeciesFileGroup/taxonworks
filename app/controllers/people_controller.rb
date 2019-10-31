class PeopleController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_person, only: [:show, :edit, :update, :destroy, :roles, :similar]
  after_action -> { set_pagination_headers(:people) }, only: [:index], if: :json_request? 

  # GET /people
  # GET /people.json
  def index
    respond_to do |format|
      format.html {
        @people = Person.order(updated_at: :desc).limit(10)
        @recent_objects = @people
        render '/shared/data/all/index'
      }
      format.json {
        @people = Queries::Person::Filter.new(filter_params).all.order(:cached).page(params[:page]).per(params[:per]) 
      }
    end
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
        format.html {redirect_to url_for(@person.metamorphosize),
                                 notice: "Person '#{@person.name}' was successfully created."}
        format.json {render action: 'show', status: :created, location: @person}
      else
        format.html {render action: 'new'}
        format.json {render json: @person.errors, status: :unprocessable_entity}
      end
    end
  end

  def similar
    @people =  Queries::Person::Filter.new(last_name: @person.last_name, first_name: @person.first_name, levenshtein_cuttoff: 3).levenshtein_similar.order(:last_name, :first_name) 
    render '/people/index'
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html {redirect_to url_for(@person.metamorphosize), notice: 'Person was successfully updated.'}
        format.json {head :no_content}
      else
        format.html {render action: 'edit'}
        format.json {render json: @person.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy!
    respond_to do |format|
      format.html {redirect_to people_url}
      format.json {head :no_content}
    end
  end

  def list
    @people = Person.order(:cached).page(params[:page])
  end

  # TODO: deprecate!
  def search
    if params[:id].blank?
      redirect_to people_path, notice: 'You must select an item from the list with a click ' \
        'or tab press before clicking show.'
    else
      redirect_to person_path(params[:id])
    end
  end

  def autocomplete
    @people = Queries::Person::Autocomplete.new(
      params.permit(:term)[:term],
      autocomplete_params
    ).autocomplete
  end

  # GET /people/select_options
  def select_options
    @people = Person.select_optimized(sessions_current_user_id, sessions_current_project_id, params[:role_type])
  end

  def merge
    @person = Person.find(params[:id]) # the person to *keep*
    person_to_remove = Person.find(params[:person_to_destroy])
    if @person.hard_merge(person_to_remove.id)
      render 'show'
    else
      render json: {status: 'Failed'}
    end
  end

  # GET /people/download
  def download
    send_data Export::Download.generate_csv(Person.all), type: 'text', filename: "people_#{DateTime.now}.csv"
  end

  # GET /people/123/roles
  def roles
  end

  # GET /people/role_types.json
  def role_types
    render json: ROLES
  end

  # GET /person/:id/details
  def details
    @person = Person.includes(:roles).find(params[:id])
    render partial: '/people/picker_details', locals: {person: @person}
  end

  private

  def filter_params
    params.permit(:last_name, :first_name, :last_name_starts_with, roles: [])
  end

  def autocomplete_params
    params.permit(roles: []).to_h.symbolize_keys
  end

  def set_person
    @person = Person.find(params[:id])
    @recent_object = @person
  end

  def person_params
    params.require(:person).permit(
        :type,
        :last_name, :first_name,
        :suffix, :prefix,
        :year_born, :year_died, :year_active_start, :year_active_end
    )
  end

  def merge_params
    params.require(:person).permit(
        :old_person_id,
        :new_person_id
    )
  end
end
