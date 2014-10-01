require 'rails_helper'

describe ProjectsHelper do
  context 'a project needs some helpers' do
    before(:all) {
      @project  = FactoryGirl.build_stubbed(:valid_project, id: 1)
      @cvt_name = @project.name
    }

    specify '::project_tag' do
      expect(ProjectsHelper.project_tag(@project)).to eq(@cvt_name)
    end

    specify '#project_tag' do
      expect(project_tag(@project)).to eq(@cvt_name)
    end

    specify '#project_link' do
      session[:project_id] = 1
      expect(project_link(@project)).to have_link(@cvt_name)
    end

    specify "#project_search_form" do
      expect(projects_search_form).to have_button('Show')
      expect(projects_search_form).to have_field('project_id_for_quick_search_form')
    end

  end
end
