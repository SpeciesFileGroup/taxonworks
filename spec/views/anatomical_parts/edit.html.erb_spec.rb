require 'rails_helper'

RSpec.describe "anatomical_parts/edit", type: :view do
  let(:anatomical_part) {
    AnatomicalPart.create!(
      name: "MyText",
      uri: "MyText",
      uri_label: "MyText",
      is_material: false
    )
  }

  before(:each) do
    assign(:anatomical_part, anatomical_part)
  end

  it "renders the edit anatomical_part form" do
    render

    assert_select "form[action=?][method=?]", anatomical_part_path(anatomical_part), "post" do

      assert_select "textarea[name=?]", "anatomical_part[name]"

      assert_select "textarea[name=?]", "anatomical_part[uri]"

      assert_select "textarea[name=?]", "anatomical_part[uri_label]"

      assert_select "input[name=?]", "anatomical_part[is_material]"
    end
  end
end
