require 'rails_helper'

describe "otus/edit", :type => :view do
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
    end
  end
end
