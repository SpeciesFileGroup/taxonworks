require 'rails_helper'

RSpec.describe "descriptors/edit", type: :view do
  before(:each) do
    @descriptor = assign(:descriptor, Descriptor.create!(
      :name => "MyString",
      :short_name => "MyString",
      :type => "",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders the edit descriptor form" do
    render

    assert_select "form[action=?][method=?]", descriptor_path(@descriptor), "post" do

      assert_select "input#descriptor_name[name=?]", "descriptor[name]"

      assert_select "input#descriptor_short_name[name=?]", "descriptor[short_name]"

      assert_select "input#descriptor_type[name=?]", "descriptor[type]"

      assert_select "input#descriptor_created_by_id[name=?]", "descriptor[created_by_id]"

      assert_select "input#descriptor_updated_by_id[name=?]", "descriptor[updated_by_id]"

      assert_select "input#descriptor_project_id[name=?]", "descriptor[project_id]"
    end
  end
end
