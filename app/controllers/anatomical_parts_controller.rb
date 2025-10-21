class AnatomicalPartsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_anatomical_part, only: %i[ show edit update destroy ]
  after_action -> { set_pagination_headers(:anatomical_parts) }, only: [:index, :api_index], if: :json_request?

  # GET /anatomical_parts or /anatomical_parts.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = AnatomicalPart
          .where(project_id: sessions_current_project_id)
          .order(updated_at: :desc).limit(10)

        render '/shared/data/all/index'
      end
      format.json do
        @anatomical_parts = ::Queries::AnatomicalPart::Filter.new(params).all
          .page(params[:page])
          .per(params[:per])
          .order('anatomical_parts.cached')
      end
    end
  end

  # GET /anatomical_parts/1 or /anatomical_parts/1.json
  def show
  end

  # GET /anatomical_parts/new
  def new
    redirect_to anatomical_parts_graph_task_path
  end

  # GET /anatomical_parts/1/edit
  def edit
    redirect_to edit_anatomical_part_task_path anatomical_part_id: @anatomical_part.id
  end

  # POST /anatomical_parts or /anatomical_parts.json
  def create
    @anatomical_part = AnatomicalPart.new(anatomical_part_params)
    if @anatomical_part.save
      @origin_relationship = @anatomical_part.inbound_origin_relationship
      render :show, status: :created
    else
      render json: { errors: @anatomical_part.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /anatomical_parts/1.json
  def update
    if @anatomical_part.update(anatomical_part_params)
      render :show, status: :ok, location: @anatomical_part
    else
      render json: @anatomical_part.errors, status: :unprocessable_entity
    end
  end

  # DELETE /anatomical_parts/1 or /anatomical_parts/1.json
  def destroy
    @anatomical_part.destroy!

    respond_to do |format|
      format.html {
        redirect_to anatomical_parts_path,
          notice: 'Anatomical part was successfully destroyed.',
          status: :see_other
      }
      format.json {
        head :no_content
      }
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    respond_to do |format|
      format.html {
        flash[:alert] = @anatomical_part.errors.full_messages.to_sentence
        redirect_back(fallback_location: anatomical_parts_path)
      }
      format.json {
        render json: { errors: @anatomical_part.errors.full_messages },
          status: :unprocessable_entity
      }
    end
  end

  def list
    @anatomical_parts = AnatomicalPart
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
  end

  def autocomplete
    @anatomical_parts = ::Queries::AnatomicalPart::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id,
    ).autocomplete
  end

  def search
    if params[:id].blank?
      redirect_to(anatomical_part_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to anatomical_part_path(params[:id])
    end
  end

  def select_options
    @anatomical_parts = AnatomicalPart.select_optimized(sessions_current_user_id, sessions_current_project_id, params[:target])
  end

  def graph
    @nodes, @origin_relationships =
      AnatomicalPart.graph(params.require(:id), params.require(:type))
  end

  def ontologies
    render json: ::Hookkaido.ontologies
  end

  def children_of
    @origin_relationships = OriginRelationship
      .where(
        old_object_id: params[:parent_id],
        old_object_type: params[:parent_type],
        new_object_type: 'AnatomicalPart'
      )
      .includes(:new_object)

      render json: @origin_relationships.map(&:new_object)
  end

  def ontology_autocomplete
    ontologies = params[:ontologies] || ['uberon']
    @term = params[:term]
    @parts_list = ::Hookkaido.search(@term, ontologies:)
    @parts_list = @parts_list[:results]
  end

  private

  def set_anatomical_part
    @anatomical_part = AnatomicalPart.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def anatomical_part_params
    params.require(:anatomical_part).permit(:name, :uri, :uri_label,
      :is_material, :preparation_type_id, :preparation_type,
      inbound_origin_relationship_attributes: [:old_object_id, :old_object_type])
  end
end
