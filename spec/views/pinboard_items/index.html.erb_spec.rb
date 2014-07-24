require 'rails_helper'

RSpec.describe "pinboard_items/index", :type => :view do
  before(:each) do
    assign(:pinboard_items, [
      PinboardItem.create!(
        :pinned_object => nil,
        :user => nil,
        :project => nil,
        :position => 1,
        :is_inserted => false,
        :is_cross_project => false,
        :inserted_count => 2,
        :created_by_id => 3,
        :updated_by_id => 4
      ),
      PinboardItem.create!(
        :pinned_object => nil,
        :user => nil,
        :project => nil,
        :position => 1,
        :is_inserted => false,
        :is_cross_project => false,
        :inserted_count => 2,
        :created_by_id => 3,
        :updated_by_id => 4
      )
    ])
  end

  it "renders a list of pinboard_items" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
