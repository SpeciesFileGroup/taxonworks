require 'rails_helper'

describe 'BiocurationClassifications', :type => :feature do

  # !! This should act more or less the same as AlternateValue features, 

  context 'resource routes' do
   #  before { 
   #    sign_in_user_and_select_project
   #  }

    # The scenario for creating biocuration classifications is in process (it has example usage in accessions/quick/verbatim_material.
    # It must handle these three calls for logged in/not logged in users.
    # It may be that these features are ultimately tested in a task.
    describe 'POST /create' do
    end

    describe 'PATCH /update' do
    end

    describe 'DELETE /destroy' do
    end
  end

end
