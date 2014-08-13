class Project < ActiveRecord::Base
  include Housekeeping::Users

  store_accessor :workbench_settings, :worker_tasks, :workbench_starting_path

  DEFAULT_WORKBENCH_STARTING_PATH = '/hub'
  DEFAULT_WORKBENCH_SETTINGS      = {
    'workbench_starting_path' => DEFAULT_WORKBENCH_STARTING_PATH
  }

  has_many :project_members, dependent: :restrict_with_error
  has_many :users, through: :project_members
  has_many :sources, through: :project_sources
  has_many :project_sources, dependent: :restrict_with_error

  after_initialize :set_default_workbench_settings

  validates_presence_of :name

  def clear_workbench_settings
    self.update('workbench_settings' => DEFAULT_WORKBENCH_SETTINGS)
  end

  # TODO: wrap this in an authentication layer, and protect it?

  def nuke
    begin
      ActiveRecord::Base.descendants.each do |d|
        if d.ancestors.map(&:to_s).include?('Housekeeping') && d.column_names.include?('project_id')
          d.where(project_id: id).delete_all
        end
      end
    rescue
      raise
    end
  end

  protected

  def set_default_workbench_settings
    self.workbench_settings = DEFAULT_WORKBENCH_SETTINGS.merge(self.workbench_settings ||= {})
  end

  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

end
