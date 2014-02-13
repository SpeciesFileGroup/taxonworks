require 'spec_helper'

describe "otus/edit" do
  before(:each) do
    @otu = assign(:otu, stub_model(Otu,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit otu form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_path(@otu), "post" do
      assert_select "input#otu_name[name=?]", "otu[name]"
      assert_select "input#otu_created_by_id[name=?]", "otu[created_by_id]"
      assert_select "input#otu_updated_by_id[name=?]", "otu[updated_by_id]"
      assert_select "input#otu_project_id[name=?]", "otu[project_id]"
    end
  end
end
