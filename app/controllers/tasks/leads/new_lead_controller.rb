class Tasks::Leads::NewLeadController < ApplicationController
  include TaskControllerConfiguration
  include LeadTaskRedirection

  before_action :redirect_if_virtual

end