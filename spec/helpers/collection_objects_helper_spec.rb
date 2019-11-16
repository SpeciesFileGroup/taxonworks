require 'rails_helper'

describe CollectionObjectsHelper, type: :helper do

  let(:collection_object) { FactoryBot.create(:valid_specimen) }

  specify '#collection_object_tag' do
    assign(:collection_object, collection_object)

    expect(helper.collection_object_tag(collection_object)).to match(collection_object.type)
  end

  specify '#collection_object_link' do
    expect(helper.collection_object_link(collection_object)).to have_link(collection_object.type)
  end

  specify '#collection_object_search_form' do
    expect(helper.collection_objects_search_form).to have_field('collection_object_id_for_quick_search_form')
  end


end
