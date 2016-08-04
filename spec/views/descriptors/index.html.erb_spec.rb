require 'rails_helper'

RSpec.describe "descriptors/index", type: :view do
  before(:each) do
    assign(:descriptors, [
      Descriptor.create!(
        :name => "Name",
        :short_name => "Short Name",
        :type => "Type",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project => nil
      ),
      Descriptor.create!(
        :name => "Name",
        :short_name => "Short Name",
        :type => "Type",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project => nil
      )
    ])
  end

  it "renders a list of descriptors" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Short Name".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
