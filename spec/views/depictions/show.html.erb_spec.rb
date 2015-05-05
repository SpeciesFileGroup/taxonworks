require 'rails_helper'

RSpec.describe "depictions/show", type: :view do
  before(:each) do
    @depiction = assign(:depiction, Depiction.create!(
      :depiction_object => "",
      :image => nil,
      :created_by_id => 1,
      :updated_by_id => 2,
      :project => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
