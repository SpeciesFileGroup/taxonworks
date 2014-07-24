require 'rails_helper'

RSpec.describe "pinboard_items/show", :type => :view do
  before(:each) do
    @pinboard_item = assign(:pinboard_item, PinboardItem.create!(
      :pinned_object => nil,
      :user => nil,
      :project => nil,
      :position => 1,
      :is_inserted => false,
      :is_cross_project => false,
      :inserted_count => 2,
      :created_by_id => 3,
      :updated_by_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
