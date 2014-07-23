require 'rails_helper'

describe "otus/new", :type => :view do
  before(:each) do
    assign(:otu, stub_model(Otu,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new otu form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otus_path, "post" do
      assert_select "input#otu_name[name=?]", "otu[name]"
    end
  end
end
