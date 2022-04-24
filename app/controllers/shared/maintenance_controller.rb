class Shared::MaintenanceController < ApplicationController
  before_action :require_sign_in_and_project_selection

  # Reorder ids of type relation in the context of a base object as found by global_id
  # POST /shared/maintenance/reorder?global_id=<>&relation=identifiers&order[]=id1&order[]=id2...
  def reorder
    begin
      o = GlobalID::Locator.locate(params.require(:global_id))
      if o.project_id != sessions_current_project_id
        render json: {}, status: :not_found and return
      end

      relation = params.require(:relation)
      ids = params.require(:order)
      safe_list = o.send(relation.to_sym).pluck(:id)

      # You must reorder all records
      if !(ids - safe_list).empty?
        render json: {}, status: :not_found and return
      end

      # Finally do the reorder
      ids.each_with_index do |id, i|
        klass.find(id).update_column(:position, i + 1)
      end

      render json: {}, status: :ok
    rescue ActionController::ParameterMissing
      render json: {}, status: :unprocessable_entity
    end
  end
end
