class AnnotationsController < ApplicationController

  before_action :require_sign_in_and_project_selection

  # GET /annotations/:global_id/metadata
  def metadata
    @object = GlobalID::Locator.locate(params.require(:global_id))
    render(json: { success: false}, status: :not_found) and return if @object.nil?
    render(json: { 'message' => 'Record not found' }, status: :unauthorized) if !@object.is_community? && @object.project_id != sessions_current_project_id
  end

  # GET /annotations/types (JSON)
  def types
  end

  # POST
  def move
    @from_object = GlobalID::Locator.locate(params.require(:from_global_id))
    @to_object = GlobalID::Locator.locate(params.require(:to_global_id))

    render(json: { success: false}, status: :not_found) and return if @from_object.nil? || @to_object.nil?

    e = @from_object.move_annotations(
      to_object: @to_object,
      except: params[:except],
      only: params[:only]
    )

    if e.empty?
      render json: {from_object: @from_object, to_object: @to_object}
    else
      render json: {success: false, errors: e }, status: :unprocessable_entity
    end
  end

  def move_one
    @to_object = GlobalID::Locator.locate(params.require(:to_global_id))
    @annotation = GlobalID::Locator.locate(params.require(:annotation_global_id))

    render(json: { success: false}, status: :not_found) and return if @to_object.nil? || @annotation.nil?

    respond_to do |format|
      if @annotation.update(annotated_object: @to_object)
        format.json { render :show, status: :ok, location: @annotation }
      else
        render json: {success: false}, status: :unprocessable_entity
      end
    end
  end

end
