require 'spec_helper'

describe "namespaces/edit" do
  before(:each) do
    @namespace = assign(:namespace, stub_model(Namespace,
      :institution => "MyString",
      :name => "MyString",
      :short_name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit namespace form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", namespace_path(@namespace), "post" do
      assert_select "input#namespace_institution[name=?]", "namespace[institution]"
      assert_select "input#namespace_name[name=?]", "namespace[name]"
      assert_select "input#namespace_short_name[name=?]", "namespace[short_name]"
      assert_select "input#namespace_created_by_id[name=?]", "namespace[created_by_id]"
      assert_select "input#namespace_updated_by_id[name=?]", "namespace[updated_by_id]"
    end
  end
end
