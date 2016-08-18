require 'rails_helper'

RSpec.describe "origin_relationships/show", type: :view do
  before(:each) do
    @origin_relationship = assign(:origin_relationship, OriginRelationship.create!(
      :old_object => "",
      :new_object => "",
      :position => 2,
      :created_by_id => 3,
      :updated_by_id => 4,
      :project => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(//)
  end
end
