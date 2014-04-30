class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include ProjectsHelper

  before_filter :set_project_and_user_variables
  #  before_filter :redirect_to_root_unless_signed_in 
  after_filter :clear_project_and_user_variables

  def set_project_and_user_variables
    $project_id = sessions_current_project_id 
    $user_id = sessions_current_user_id 
  end

  def clear_project_and_user_variables
    $project_id = nil 
    $user_id = nil 
  end

  attr_writer   :meta_title, :meta_data, :site_name
  attr_accessor :meta_description, :meta_keywords, :page_title

  helper_method :meta_title, :meta_data, :site_name, :page_title

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
