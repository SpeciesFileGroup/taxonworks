class GraphController < ApplicationController

  before_action :require_sign_in_and_project_selection

  # GET /graph/:global_id/metadata
  def metadata
    @object = GlobalID::Locator.locate(params.require(:global_id))
    render(json: { success: false}, status: :not_found) if @object.nil?
    render(json: { 'message' => 'Record not found' }, status: :unauthorized) and return  if !@object.is_community? && @object.project_id != sessions_current_project_id
    render(json: { 'message' => "#{@object.class} is not configured for THE GRAPH"}, status: :method_not_allowed) and return unless @object.class.const_defined?('GRAPH_ENTRY_POINTS') 
  end

  def object
    @object = GlobalID::Locator.locate(params.require(:global_id))
    render(json: { success: false}, status: :not_found) if @object.nil?
  
    render json: helpers.object_graph(@object)
  end

end
