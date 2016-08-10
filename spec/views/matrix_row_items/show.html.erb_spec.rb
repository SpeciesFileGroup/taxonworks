require 'rails_helper'

RSpec.describe "matrix_row_items/show", type: :view do
  before(:each) do
    @matrix_row_item = assign(:matrix_row_item, MatrixRowItem.create!(
      :matrix => nil,
      :type => "Type",
      :collection_object => nil,
      :otu => nil,
      :keyword => nil,
      :created_by_id => 2,
      :updated_by_id => 3,
      :project => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
  end
end
