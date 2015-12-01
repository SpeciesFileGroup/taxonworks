require 'rails_helper'

RSpec.describe "documentation/index", type: :view do
  before(:each) do
    assign(:documentation, [
      Documentation.create!(
        :documentation_object => nil,
        :document => nil,
        :page_map => "",
        :project => nil,
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      Documentation.create!(
        :documentation_object => nil,
        :document => nil,
        :page_map => "",
        :project => nil,
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of documentation" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
