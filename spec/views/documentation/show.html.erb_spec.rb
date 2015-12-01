require 'rails_helper'

RSpec.describe "documentation/show", type: :view do
  before(:each) do
    @documentation = assign(:documentation, Documentation.create!(
      :documentation_object => nil,
      :document => nil,
      :page_map => "",
      :project => nil,
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
