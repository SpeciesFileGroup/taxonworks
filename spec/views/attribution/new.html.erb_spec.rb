require 'rails_helper'

RSpec.describe "attribution/new", type: :view do
  before(:each) do
    assign(:attribution, Attribution.new(
      :copyright_year => 1,
      :license => "MyString"
    ))
  end

  it "renders new attribution form" do
    render

    assert_select "form[action=?][method=?]", attribution_index_path, "post" do

      assert_select "input[name=?]", "attribution[copyright_year]"

      assert_select "input[name=?]", "attribution[license]"
    end
  end
end
