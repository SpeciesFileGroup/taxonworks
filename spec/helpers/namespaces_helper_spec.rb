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
describe NamespacesHelper, :type => :helper do
  context 'a namespace needs some helpers' do
    before(:all) {
      $user_id   = 1; $project_id = 1
      @namespace = FactoryGirl.create(:valid_namespace)
      @cvt_name  = @namespace.name
    }

    specify '::namespace_tag' do
      expect(NamespacesHelper.namespace_tag(@namespace)).to eq(@cvt_name)
    end

    specify '#namespace_tag' do
      expect(namespace_tag(@namespace)).to eq(@cvt_name)
    end

    specify '#namespace_link' do
      expect(namespace_link(@namespace)).to have_link(@cvt_name)
    end

    specify "#namespace_search_form" do
      expect(namespaces_search_form).to have_button('Show')
      expect(namespaces_search_form).to have_field('namespace_id_for_quick_search_form')
    end

  end
end
