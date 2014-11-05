require 'rails_helper'

describe PeopleHelper, :type => :helper do
  context 'a person needs some helpers' do
    let(:person) {FactoryGirl.create(:valid_person)}

    specify '.person_tag' do
      expect(helper.person_tag(person)).to eq(person.name)
    end

    specify '.person_link' do
      expect(helper.person_link(person)).to have_link(person.name)
    end

    specify ".people_search_form" do
      expect(helper.people_search_form).to have_button('Show')
      expect(helper.people_search_form).to have_field('person_id_for_quick_search_form')
    end

  end

end
