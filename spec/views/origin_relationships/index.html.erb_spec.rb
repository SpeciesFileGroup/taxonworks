require 'rails_helper'

RSpec.describe "origin_relationships/index", type: :view do
  before(:each) do
    assign(:origin_relationships, [
      OriginRelationship.create!(
        :old_object => "",
        :new_object => "",
        :position => 2,
        :created_by_id => 3,
        :updated_by_id => 4,
        :project => nil
      ),
      OriginRelationship.create!(
        :old_object => "",
        :new_object => "",
        :position => 2,
        :created_by_id => 3,
        :updated_by_id => 4,
        :project => nil
      )
    ])
  end

  it "renders a list of origin_relationships" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
