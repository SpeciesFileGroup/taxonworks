class Project < ActiveRecord::Base
  include Housekeeping::Users

  store_accessor :workbench_settings, :worker_tasks, :workbench_starting_path

  DEFAULT_WORKBENCH_STARTING_PATH = '/hub'
  DEFAULT_WORKBENCH_SETTINGS = {
    'workbench_starting_path' => DEFAULT_WORKBENCH_STARTING_PATH
  }

  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members
  has_many :sources, through: :project_sources
  has_many :project_sources, dependent: :destroy

  after_initialize :set_default_workbench_settings

  validates_presence_of :name

  def clear_workbench_settings
    self.update('workbench_settings' => DEFAULT_WORKBENCH_SETTINGS)
  end

  protected
  def set_default_workbench_settings
    self.workbench_settings = DEFAULT_WORKBENCH_SETTINGS.merge(self.workbench_settings ||= {})
  end

end
