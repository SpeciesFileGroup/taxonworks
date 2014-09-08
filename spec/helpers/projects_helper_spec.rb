require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

describe ProjectsHelper, :type => :helper do
  context 'a project needs some helpers' do
    before(:all) {
      $user_id  = 1 ; $project_id = 1
      @project  = FactoryGirl.create(:valid_project)
      @cvt_name = @project.name
    }

    specify '::project_tag' do
      expect(ProjectsHelper.project_tag(@project)).to eq(@cvt_name)
    end

    specify '#project_tag' do
      expect(project_tag(@project)).to eq(@cvt_name)
    end

    specify '#project_link' do
      expect(project_link(@project)).to have_link(@cvt_name)
    end

    specify "#project_search_form" do
      expect(projects_search_form).to have_button('Show')
      expect(projects_search_form).to have_field('project_id_for_quick_search_form')
    end

  end
end
