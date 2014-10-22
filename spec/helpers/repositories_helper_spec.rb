require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the LoansHelper. For example:
#
# describe LoansHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe RepositoriesHelper, :type => :helper do
  context 'a repository needs some helpers' do
    before(:all) {
      @repository = FactoryGirl.create(:valid_repository)
      @cvt_name   = @repository.name
    }

    specify '::repository_tag' do
      expect(RepositoriesHelper.repository_tag(@repository)).to eq(@cvt_name)
    end

    specify '#repository_tag' do
      expect(repository_tag(@repository)).to eq(@cvt_name)
    end

    specify '#repository_link' do
      expect(repository_link(@repository)).to have_link(@cvt_name)
    end

    specify "#repositoies_search_form" do
      expect(repositories_search_form).to have_button('Show')
      expect(repositories_search_form).to have_field('repository_id_for_quick_search_form')
    end

  end
end
