class Tasks::Leads::CiteKeyController < ApplicationController
  include TaskControllerConfiguration
  include LeadTaskRedirection

  before_action :redirect_if_not_virtual

end