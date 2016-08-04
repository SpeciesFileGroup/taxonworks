require 'rails_helper'

RSpec.describe "descriptors/show", type: :view do
  before(:each) do
    @descriptor = assign(:descriptor, Descriptor.create!(
      :name => "Name",
      :short_name => "Short Name",
      :type => "Type",
      :created_by_id => 2,
      :updated_by_id => 3,
      :project => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Short Name/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
  end
end
