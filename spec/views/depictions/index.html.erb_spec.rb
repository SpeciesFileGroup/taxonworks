require 'rails_helper'

RSpec.describe "depictions/index", type: :view do
  before(:each) do
    assign(:depictions, [
      Depiction.create!(
        :depiction_object => "",
        :image => nil,
        :created_by_id => 1,
        :updated_by_id => 2,
        :project => nil
      ),
      Depiction.create!(
        :depiction_object => "",
        :image => nil,
        :created_by_id => 1,
        :updated_by_id => 2,
        :project => nil
      )
    ])
  end

  it "renders a list of depictions" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
