require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the TaxonNamesHelper. For example:
#
# describe TaxonNamesHelper do
#   describe "string concat" do
#     it "concatenates two strings with spaces" do
#       expect(helper.concat_strings("this", "that")).to eq("this that")
#     end
#   end
# end
describe CollectionObjectsHelper, :type => :helper do
  context 'a collection_object needs some helpers' do
    before(:all) {
      $user_id           = 1; $project_id = 1
      @collection_object = FactoryGirl.create(:valid_collection_object)
      @cvt_name          = @collection_object.type
    }

    specify '::collection_object_tag' do
      expect(CollectionObjectsHelper.collection_object_tag(@collection_object)).to eq(@cvt_name)
    end

    specify '#collection_object_tag' do
      expect(collection_object_tag(@collection_object)).to eq(@cvt_name)
    end

    specify '#collection_object_link' do
      expect(collection_object_link(@collection_object)).to have_link(@cvt_name)
    end

    specify "#collection_object_search_form" do
      expect(collection_objects_search_form).to have_button('Show')
      expect(collection_objects_search_form).to have_field('collection_object_id_for_quick_search_form')
    end

  end

end
