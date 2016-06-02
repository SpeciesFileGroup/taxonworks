
# helpers specifically use in /views/layouts only
module Workbench::LayoutHelper

  def sandbox_css
    Settings.sandbox_mode? ? 'sandbox' : nil
  end

  def sandbox_details_tag
    if Settings.sandbox_mode? 
      content_tag(:span, "SANDBOX - build #{ Settings.sandbox_commit_sha } on #{ Settings.sandbox_commit_date}" )
    end 
  end

end
