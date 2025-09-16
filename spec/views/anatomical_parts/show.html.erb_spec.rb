require 'rails_helper'

RSpec.describe "anatomical_parts/show", type: :view do
  before(:each) do
    assign(:anatomical_part, AnatomicalPart.create!(
      name: "MyText",
      uri: "MyText",
      uri_label: "MyText",
      is_material: false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
  end
end
