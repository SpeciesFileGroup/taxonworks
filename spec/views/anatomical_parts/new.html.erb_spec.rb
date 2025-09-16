require 'rails_helper'

RSpec.describe "anatomical_parts/new", type: :view do
  before(:each) do
    assign(:anatomical_part, AnatomicalPart.new(
      name: "MyText",
      uri: "MyText",
      uri_label: "MyText",
      is_material: false
    ))
  end

  it "renders new anatomical_part form" do
    render

    assert_select "form[action=?][method=?]", anatomical_parts_path, "post" do

      assert_select "textarea[name=?]", "anatomical_part[name]"

      assert_select "textarea[name=?]", "anatomical_part[uri]"

      assert_select "textarea[name=?]", "anatomical_part[uri_label]"

      assert_select "input[name=?]", "anatomical_part[is_material]"
    end
  end
end
