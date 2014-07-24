require 'rails_helper'

RSpec.describe "pinboard_items/edit", :type => :view do
  before(:each) do
    @pinboard_item = assign(:pinboard_item, PinboardItem.create!(
      :pinned_object => nil,
      :user => nil,
      :project => nil,
      :position => 1,
      :is_inserted => false,
      :is_cross_project => false,
      :inserted_count => 1,
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit pinboard_item form" do
    render

    assert_select "form[action=?][method=?]", pinboard_item_path(@pinboard_item), "post" do

      assert_select "input#pinboard_item_pinned_object_id[name=?]", "pinboard_item[pinned_object_id]"

      assert_select "input#pinboard_item_user_id[name=?]", "pinboard_item[user_id]"

      assert_select "input#pinboard_item_project_id[name=?]", "pinboard_item[project_id]"

      assert_select "input#pinboard_item_position[name=?]", "pinboard_item[position]"

      assert_select "input#pinboard_item_is_inserted[name=?]", "pinboard_item[is_inserted]"

      assert_select "input#pinboard_item_is_cross_project[name=?]", "pinboard_item[is_cross_project]"

      assert_select "input#pinboard_item_inserted_count[name=?]", "pinboard_item[inserted_count]"

      assert_select "input#pinboard_item_created_by_id[name=?]", "pinboard_item[created_by_id]"

      assert_select "input#pinboard_item_updated_by_id[name=?]", "pinboard_item[updated_by_id]"
    end
  end
end
