require 'rails_helper'

describe "projects/show", :type => :view do
  before(:each) do
    @project = assign(:project, stub_model(Project,
      :name => "Name",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
