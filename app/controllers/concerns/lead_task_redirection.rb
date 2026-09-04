module LeadTaskRedirection
  extend ActiveSupport::Concern

  protected

  # Redirect virtual (simple) leads to the cite_key task. Task controllers
  # structured around dichotomous couplets don't handle virtual leads.
  def redirect_if_virtual
    lead = lead_for_redirect
    return unless lead&.is_virtual

    redirect_to cite_key_task_path(lead_id: lead.id)
  end

  # Redirect non-virtual leads to the new_lead task. The cite_key task only
  # edits simple keys.
  def redirect_if_not_virtual
    lead = lead_for_redirect
    return unless lead && !lead.is_virtual

    redirect_to new_lead_task_path(lead_id: lead.id)
  end

  private

  def lead_for_redirect
    return @lead if defined?(@lead) && @lead
    return nil if params[:lead_id].blank?

    Lead.where(project_id: sessions_current_project_id).find_by(id: params[:lead_id])
  end
end
