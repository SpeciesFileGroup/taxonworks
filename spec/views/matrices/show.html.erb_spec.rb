require 'rails_helper'

RSpec.describe "matrices/show", type: :view do
  before(:each) do
    @matrix = assign(:matrix, Matrix.create!(
      :name => "Name",
      :created_by_id => 2,
      :updated_by_id => 3,
      :project => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
  end
end
