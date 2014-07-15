class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include ProjectsHelper

  before_filter :set_project_and_user_variables
  after_filter :clear_project_and_user_variables

  def set_project_and_user_variables
    $project_id = sessions_current_project_id 
    $user_id = sessions_current_user_id 
  end

  def clear_project_and_user_variables
    $project_id = nil 
    $user_id = nil 
  end

  # In use
  attr_writer :is_data_controller, :is_task_controller 

  # Potentially used
  attr_writer   :meta_title, :meta_data, :site_name
  attr_accessor :meta_description, :meta_keywords, :page_title

  # In use 
  helper_method :is_data_controller?, :is_task_controller?

  # Potentially used.
  helper_method :meta_title, :meta_data, :site_name, :page_title

  # Returns true if the controller is that of data class. See controllers/concerns/data_controller_configuration/ concern.
  # Data controllers can not be task controllers.
  def is_data_controller?
    @is_data_controller
  end

  # Returns true if the controller is a task controller. See controllers/concerns/task_controller_configuration/ concern.
  # Task controllers can not be data controllers.
  def is_task_controller?
    @is_task_controller
  end

  def meta_title
    @meta_title ||= [@meta_title.presence || @page_title.presence, site_name].
                    compact.join(' | ')
  end

  def meta_data
    @meta_data ||= {
      description: @meta_description,
      keywords: @meta_keywords
    }.delete_if{ |k, v| v.nil? }
  end

  def site_name
    @site_name ||= 'TaxonWorks'
  end

end
