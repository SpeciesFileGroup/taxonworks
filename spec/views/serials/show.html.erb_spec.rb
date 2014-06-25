require 'spec_helper'

describe "serials/show" do
  before(:each) do
    @serial = assign(:serial, stub_model(Serial,
      :name => "Name",
      :created_by_id => 1,
      :updated_by_id => 2,
      :project_id => 3,
      :publisher => "Publisher",
      :place_published => "Place Published",
      :primary_language_id => 4,
      :first_year_of_issue => 5,
      :last_year_of_issue => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/Publisher/)
    rendered.should match(/Place Published/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end
