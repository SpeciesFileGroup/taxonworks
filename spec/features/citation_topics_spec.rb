require 'rails_helper'

describe 'CitationTopics', :type => :feature do

   # !! See related patterns in AlternateValues and BiocurationClassifcations
  
   #  before { 
   #    sign_in_user_and_select_project
   #  }

  context 'resource routes' do

    # The scenario for creating citation topics has not been developed. 
    # It must handle these three calls for logged in/not logged in users.
    # It may be that these features are ultimately tested in a task.
    describe 'POST /create' do
    end

    describe 'PATCH /update' do
    end

    describe 'DELETE /destroy' do
    end

    describe 'the partial form rendered in context of NEW/EDIT on some other page' do
    end

  end

end
