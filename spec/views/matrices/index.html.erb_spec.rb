require 'rails_helper'

RSpec.describe "matrices/index", type: :view do
  before(:each) do
    assign(:matrices, [
      Matrix.create!(
        :name => "Name",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project => nil
      ),
      Matrix.create!(
        :name => "Name",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project => nil
      )
    ])
  end

  it "renders a list of matrices" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
