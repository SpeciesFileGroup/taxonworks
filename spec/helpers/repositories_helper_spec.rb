require 'rails_helper'

describe RepositoriesHelper, :type => :helper do
  context 'a repository needs some helpers' do
    let(:repository) {FactoryGirl.create(:valid_repository)}
    let(:tag) {"#{repository.name} (#{repository.acronym})"}

    specify '.repository_tag' do
      expect(helper.repository_tag(repository)).to eq(tag)
    end

    specify '.repository_link' do
      expect(helper.repository_link(repository)).to have_link(repository.name)
    end

    specify ".repositories_search_form" do
      expect(helper.repositories_search_form).to have_button('Show')
      expect(helper.repositories_search_form).to have_field('repository_id_for_quick_search_form')
    end

  end
end
