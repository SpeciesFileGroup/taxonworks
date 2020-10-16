
# helpers specifically use in /views/layouts only
module Workbench::LayoutHelper

  def sandbox_css
    Settings.sandbox_mode? ? 'sandbox' : nil
  end

  def taxonworks_version_tag
    unless Settings.sandbox_mode?
      link_to("v#{Taxonworks::VERSION}", "https://github.com/SpeciesFileGroup/taxonworks/releases/tag/v#{Taxonworks::VERSION}", id: 'taxonworks_version')
    end
  end

  def sandbox_details_tag
    if Settings.sandbox_mode? 
      content_tag(:span) do
        [ 'SANDBOX - build',
          (Settings.sandbox_short_commit_sha ?
           link_to(Settings.sandbox_short_commit_sha, 'https://github.com/SpeciesFileGroup/taxonworks/tree/' + Settings.sandbox_commit_sha, class: [:font_subtitle]) :
           'unknown SHA'
          ),
          'on',  
          ( Settings.sandbox_commit_date  ?  Settings.sandbox_commit_date : 'date unknown')
        ].join(' ').html_safe
      end
    end 
  end

end
