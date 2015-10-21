require 'rails_helper'

describe NamespacesHelper, :type => :helper do
  context 'a namespace needs some helpers' do
    let(:name) {'dangerzone'}
    let(:namespace) {FactoryGirl.create(:valid_namespace, name:name)}

    specify '::namespace_tag' do
      expect(helper.namespace_tag(namespace)).to eq(name)
    end

    specify '#namespace_tag' do
      expect(helper.namespace_tag(namespace)).to eq(name)
    end

    specify '#namespace_link' do
      expect(helper.namespace_link(namespace)).to have_link(name)
    end

    specify "#namespace_search_form" do
      expect(helper.namespaces_search_form).to have_button('Show')
      expect(helper.namespaces_search_form).to have_field('namespace_id_for_quick_search_form')
    end

  end
end
