require 'rails_helper'

describe "serials/show", :type => :view do
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
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Publisher/)
    expect(rendered).to match(/Place Published/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
