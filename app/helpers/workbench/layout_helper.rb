
# helpers specifically use in /views/layouts only
module Workbench::LayoutHelper

  def sandbox_css
    Settings.sandbox_mode? ? 'sandbox' : nil
  end

  def sandbox_details_tag
    if Settings.sandbox_mode? 
      content_tag(:span) do
        [ 'SANDBOX - build',
          link_to(Settings.sandbox_commit_sha[0..7], 'https://github.com/SpeciesFileGroup/taxonworks/tree/' + Settings.sandbox_commit_sha, class: [:regular_type]), 
          'on',  
          Settings.sandbox_commit_date 
        ].join(' ').html_safe
      end
    end 
  end

end
