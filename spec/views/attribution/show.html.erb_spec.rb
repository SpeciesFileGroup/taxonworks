require 'rails_helper'

RSpec.describe "attribution/show", type: :view do
  before(:each) do
    @attribution = assign(:attribution, Attribution.create!(
      :copyright_year => 2,
      :license => "License"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/License/)
  end
end
