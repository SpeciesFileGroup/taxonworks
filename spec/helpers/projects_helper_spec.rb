require 'rails_helper'

describe ProjectsHelper do
  context 'a project needs some helpers' do
    let(:name) {'Wonderland'}
    let(:project) {FactoryGirl.build_stubbed(:valid_project, id: 1, name:name) }

    specify '::project_tag' do
      expect(helper.project_tag(project)).to eq(name)
    end

    specify '#project_tag' do
      expect(helper.project_tag(project)).to eq(name)
    end

    specify '#project_link' do
      session[:project_id] = 1
      expect(helper.project_link(project)).to have_link(name)
    end

    specify "#project_search_form" do
      expect(projects_search_form).to have_button('Show')
      expect(projects_search_form).to have_field('project_id_for_quick_search_form')
    end

  end
end
