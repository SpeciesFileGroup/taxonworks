require 'rails_helper'

RSpec.describe "attribution/index", type: :view do
  before(:each) do
    assign(:attribution, [
      Attribution.create!(
        :copyright_year => 2,
        :license => "License"
      ),
      Attribution.create!(
        :copyright_year => 2,
        :license => "License"
      )
    ])
  end

  it "renders a list of attribution" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "License".to_s, :count => 2
  end
end
