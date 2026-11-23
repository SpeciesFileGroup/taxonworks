# Quick mobile material: stub CollectionObjects from Images POSTed by a
# Mobile app, authenticated with a task_token (see TaskTokenAuthentication).
#
# Session actions: index, issue, invalidate, token_status, items
# Token actions (config/routes/task_token.rb): capture
#
class Tasks::CollectionObjects::QuickMobileMaterialController < ApplicationController
  include TaskControllerConfiguration
  include TaskTokenAuthentication

  task_token_origin :quick_mobile_material_task
  task_token_lifetime 2.hours
  task_token_actions :capture

  # GET
  def index
  end

  # POST /tasks/collection_objects/quick_mobile_material/task_token.json
  #   composition_id (required), repository_id, namespace_id
  # Issues a new 2 minute token for the QR code, ending any prior token for
  # this Task.
  def issue
    composition = Layout::Task.where(project_id: sessions_current_project_id).find(params.require(:composition_id))

    attributes = {
      composition_id: composition.id,
      repository_id: Repository.where(id: params[:repository_id]).pick(:id),
      namespace_id: Namespace.where(id: params[:namespace_id]).pick(:id)
    }.compact

    issued = issue_task_token(attributes:)

    qr = {
      task_token: issued.token,
      user_id: Current.user_id,
      project_id: Current.project_id,
      composition_id: composition.id,
      endpoint: capture_quick_mobile_material_task_path,
      expires_at: issued.expires_at.utc.iso8601
    }

    render json: {
      svg: helpers.qr_code_svg(qr.to_json),
      expires_at: qr[:expires_at],
      task_token_status: task_token_status_json
    }
  end

  # DELETE /tasks/collection_objects/quick_mobile_material/task_token.json
  def invalidate
    invalidate_task_token
    render json: { task_token_status: nil }
  end

  # GET /tasks/collection_objects/quick_mobile_material/task_token.json
  def token_status
    render json: { task_token_status: task_token_status_json }
  end

  # GET /tasks/collection_objects/quick_mobile_material/items.json?composition_id=
  def items
    @composition = Layout::Task.where(project_id: sessions_current_project_id).find(params.require(:composition_id))
    @task_items = LayoutItem::TaskItem
      .where(composition_id: @composition.id)
      .includes(composition_item_object: [:identifiers, { depictions: :image }])
      .order(:position)
  end

  # POST /tasks/collection_objects/quick_mobile_material/capture.json (task_token)
  def capture
    r = TaskCapture::QuickMobileMaterial.new(
      composition_id: task_token_attributes['composition_id'],
      repository_id: task_token_attributes['repository_id'],
      namespace_id: task_token_attributes['namespace_id'],
      params: params.permit(*TaskCapture::QuickMobileMaterial::PERMITTED_PARAMS).to_h
    ).call

    render json: r.body, status: r.status
  end

  private

  # @return [Hash, nil] state (pending, active) and expires_at, never the jti
  def task_token_status_json
    task_token_status&.slice('state', 'expires_at')
  end

end
