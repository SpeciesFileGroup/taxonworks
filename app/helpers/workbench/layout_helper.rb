
# helpers specifically use in /views/layouts only
module Workbench::LayoutHelper

  def sandbox_css
    Settings.sandbox_mode? ? 'sandbox' : nil
  end

  def sandbox_details_tag
    if Settings.sandbox_mode? 
      content_tag(:span) do
        [ 'SANDBOX - build',
          (Settings.sandbox_short_commit_sha ?
           link_to(Settings.sandbox_short_commit_sha, 'https://github.com/SpeciesFileGroup/taxonworks/tree/' + Settings.sandbox_commit_sha, class: [:regular_type]) :
           'unknown SHA'
          ),
          'on',  
          ( Settings.sandbox_commit_date  ?  Settings.sandbox_commit_date : 'date unknown')
        ].join(' ').html_safe
      end
    end 
  end

end
