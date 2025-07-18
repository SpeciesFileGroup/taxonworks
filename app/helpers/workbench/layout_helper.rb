
# helpers specifically use in /views/layouts only
module Workbench::LayoutHelper

  def sandbox_css
    Settings.sandbox_mode? ? 'sandbox' : nil
  end

  def navbar_css
    Rails.env.production? ? 'header_production' : 'header_development'
  end

  def development_header_tag
    if Rails.env.development? 
      content_tag(:span, 'DEVELOPMENT', class: 'text-warning-color')
    end 
  end

  def taxonworks_version_tag
    unless Settings.sandbox_mode?
      link_to("v#{TaxonWorks::VERSION}", "https://github.com/SpeciesFileGroup/taxonworks/releases/tag/v#{TaxonWorks::VERSION}", id: 'taxonworks_version')
    end
  end

  def sandbox_details_tag
    if Settings.sandbox_mode? 
      content_tag(:span, class: 'subtle') do
        [ '<span data-icon="warning"></span> SANDBOX - TEMPORARY <span data-icon="warning"></span> build',
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

  def sandbox_warning_tag
    if Settings.sandbox_mode?
      content_tag(:i, 'All data may be deleted at any time without warning', class: 'text-white-color')
    end
  end

  def issue_tracker_tag
    [
      link_to(
        'Issues', 
        'https://github.com/SpeciesFileGroup/taxonworks/issues',
        target: '_blank',
        class: 'issues-link',
        data: { 'curation-issue-tracker': sessions_current_project&.data_curation_issue_tracker_url }, rel: 'noopener'
      ),
      (content_tag('div','', id: 'curation-issue-tracker-container') if sessions_current_project&.data_curation_issue_tracker_url)
    ].join().html_safe
  end

end
