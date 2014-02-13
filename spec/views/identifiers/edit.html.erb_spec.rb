require 'spec_helper'

describe "identifiers/edit" do
  before(:each) do
    @identifier = assign(:identifier, stub_model(Identifier,
      :identified_object_id => 1,
      :identified_object_type => "MyString",
      :identifier => "MyString",
      :type => "",
      :cached_identifier => "MyString",
      :namespace_id => 1,
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit identifier form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", identifier_path(@identifier), "post" do
      assert_select "input#identifier_identified_object_id[name=?]", "identifier[identified_object_id]"
      assert_select "input#identifier_identified_object_type[name=?]", "identifier[identified_object_type]"
      assert_select "input#identifier_identifier[name=?]", "identifier[identifier]"
      assert_select "input#identifier_type[name=?]", "identifier[type]"
      assert_select "input#identifier_cached_identifier[name=?]", "identifier[cached_identifier]"
      assert_select "input#identifier_namespace_id[name=?]", "identifier[namespace_id]"
      assert_select "input#identifier_created_by_id[name=?]", "identifier[created_by_id]"
      assert_select "input#identifier_updated_by_id[name=?]", "identifier[updated_by_id]"
    end
  end
end
