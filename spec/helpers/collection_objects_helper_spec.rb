require 'rails_helper'

describe CollectionObjectsHelper, :type => :helper do
  context 'a collection_object needs some helpers' do
    let(:collection_object) { FactoryGirl.create(:valid_specimen) }

    specify '::collection_object_tag' do
      expect(CollectionObjectsHelper.collection_object_tag(collection_object)).to eq(collection_object.type)
    end

    specify '#collection_object_tag' do
      expect(collection_object_tag(collection_object)).to eq(collection_object.type)
    end

    specify '#collection_object_link' do
      expect(collection_object_link(collection_object)).to have_link(collection_object.type)
    end

    specify "#collection_object_search_form" do
      expect(collection_objects_search_form).to have_button('Show')
      expect(collection_objects_search_form).to have_field('collection_object_id_for_quick_search_form')
    end

  end

end
