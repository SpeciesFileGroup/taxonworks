require 'rails_helper'

RSpec.describe "matrix_row_items/index", type: :view do
  before(:each) do
    assign(:matrix_row_items, [
      MatrixRowItem.create!(
        :matrix => nil,
        :type => "Type",
        :collection_object => nil,
        :otu => nil,
        :keyword => nil,
        :created_by_id => 2,
        :updated_by_id => 3,
        :project => nil
      ),
      MatrixRowItem.create!(
        :matrix => nil,
        :type => "Type",
        :collection_object => nil,
        :otu => nil,
        :keyword => nil,
        :created_by_id => 2,
        :updated_by_id => 3,
        :project => nil
      )
    ])
  end

  it "renders a list of matrix_row_items" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
