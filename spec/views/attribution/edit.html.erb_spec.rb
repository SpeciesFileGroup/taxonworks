require 'rails_helper'

RSpec.describe "attribution/edit", type: :view do
  before(:each) do
    @attribution = assign(:attribution, Attribution.create!(
      :copyright_year => 1,
      :license => "MyString"
    ))
  end

  it "renders the edit attribution form" do
    render

    assert_select "form[action=?][method=?]", attribution_path(@attribution), "post" do

      assert_select "input[name=?]", "attribution[copyright_year]"

      assert_select "input[name=?]", "attribution[license]"
    end
  end
end
