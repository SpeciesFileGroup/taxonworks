class AddDataCurationIssueTrackerUrlToProject < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :data_curation_issue_tracker_url, :string
  end
end
