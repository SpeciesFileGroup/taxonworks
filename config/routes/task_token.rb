# Token-only routes, see TaskTokenAuthentication and lib/task_token.
#
# * ONLY routes here accept a task_token, and every route here is token-only (no session fallback)
# * POST only
# * Paths stay under the Task's own path, the Task route is the token's origin
# * Every route sets `task_token_route: true`, which is how the concern recognizes them
#
scope :tasks do
  scope :collection_objects do
    scope :quick_mobile_material, controller: 'tasks/collection_objects/quick_mobile_material' do
      post :capture, as: 'capture_quick_mobile_material_task', defaults: { format: :json, task_token_route: true }
    end
  end
end
