require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the PeopleHelper. For example:
#
# describe PeopleHelper do
#   describe "string concat" do
#     it "concatenates two strings with spaces" do
#       expect(helper.concat_strings("this", "that")).to eq("this that")
#     end
#   end
# end
describe PeopleHelper, :type => :helper do
  context 'a person needs some helpers' do
    before(:all) {
      $user_id     = 1; $project_id = 1
      @person      = FactoryGirl.create(:valid_person)
      @person_name = @person.name
    }

    specify '::person_tag' do
      expect(PeopleHelper.person_tag(@person)).to eq(@person_name)
    end

    specify '#person_tag' do
      expect(person_tag(@person)).to eq(@person_name)
    end

    specify '#person_link' do
      expect(person_link(@person)).to have_link(@person_name)
    end

    specify "#people_search_form" do
      expect(people_search_form).to have_button('Show')
      expect(people_search_form).to have_field('person_id_for_quick_search_form')
    end

  end

end
