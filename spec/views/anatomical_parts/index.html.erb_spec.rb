require 'rails_helper'

RSpec.describe "anatomical_parts/index", type: :view do
  before(:each) do
    assign(:anatomical_parts, [
      AnatomicalPart.create!(
        name: "MyText",
        uri: "MyText",
        uri_label: "MyText",
        is_material: false
      ),
      AnatomicalPart.create!(
        name: "MyText",
        uri: "MyText",
        uri_label: "MyText",
        is_material: false
      )
    ])
  end

  it "renders a list of anatomical_parts" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
  end
end
