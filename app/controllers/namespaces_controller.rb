class NamespacesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_administrator_sign_in, only: [:edit, :update, :destroy, :index]
  before_action :set_namespace, only: [:show, :edit, :update, :destroy]

  # GET /namespaces
  # GET /namespaces.json
  def index
    @namespaces     = Namespace.all
    @recent_objects = Namespace.order(updated_at: :desc).limit(10)
  end

  # GET /namespaces/1
  # GET /namespaces/1.json
  def show
  end

  # GET /namespaces/new
  def new
    @namespace = Namespace.new
  end

  # GET /namespaces/1/edit
  def edit
  end

  # POST /namespaces
  # POST /namespaces.json
  def create
    @namespace = Namespace.new(namespace_params)

    respond_to do |format|
      if @namespace.save
        format.html { redirect_to @namespace, notice: 'Namespace was successfully created.' }
        format.json { render action: 'show', status: :created, location: @namespace }
      else
        format.html { render action: 'new' }
        format.json { render json: @namespace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /namespaces/1
  # PATCH/PUT /namespaces/1.json
  def update
    respond_to do |format|
      if @namespace.update(namespace_params)
        format.html { redirect_to @namespace, notice: 'Namespace was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @namespace.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /namespaces/1
  # DELETE /namespaces/1.json
  def destroy
    @namespace.destroy
    respond_to do |format|
      format.html { redirect_to namespaces_url }
      format.json { head :no_content }
    end
  end

  def list
    @namespaces = Namespace.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id]
      redirect_to namespace_path(params[:id])
    else
      redirect_to namespace_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def autocomplete
    @namespaces = Namespace.find_for_autocomplete(params)

    data = @namespaces.collect do |t|
      {id:              t.id,
       label:           NamespacesHelper.namespace_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      NamespacesHelper.namespace_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_namespace
    @namespace = Namespace.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def namespace_params
    params.require(:namespace).permit(:institution, :name, :short_name, :verbatim_short_name, :created_by_id, :updated_by_id)
  end
end
