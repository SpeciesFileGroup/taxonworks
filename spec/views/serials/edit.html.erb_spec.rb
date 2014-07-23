require 'rails_helper'

describe "serials/edit", :type => :view do
  before(:each) do
    @serial = assign(:serial, stub_model(Serial,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :publisher => "MyString",
      :place_published => "MyString",
      :primary_language_id => 1,
      :first_year_of_issue => 1,
      :last_year_of_issue => 1
    ))
  end

  it "renders the edit serial form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", serial_path(@serial), "post" do
      assert_select "input#serial_name[name=?]", "serial[name]"
      assert_select "input#serial_created_by_id[name=?]", "serial[created_by_id]"
      assert_select "input#serial_updated_by_id[name=?]", "serial[updated_by_id]"
      assert_select "input#serial_project_id[name=?]", "serial[project_id]"
      assert_select "input#serial_publisher[name=?]", "serial[publisher]"
      assert_select "input#serial_place_published[name=?]", "serial[place_published]"
      assert_select "input#serial_primary_language_id[name=?]", "serial[primary_language_id]"
      assert_select "input#serial_first_year_of_issue[name=?]", "serial[first_year_of_issue]"
      assert_select "input#serial_last_year_of_issue[name=?]", "serial[last_year_of_issue]"
    end
  end
end
