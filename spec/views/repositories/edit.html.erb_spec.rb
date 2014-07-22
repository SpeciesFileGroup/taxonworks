require 'rails_helper'

describe "repositories/edit" do
  before(:each) do
    @repository = assign(:repository, stub_model(Repository,
      :name => "MyString",
      :url => "MyString",
      :acronym => "MyString",
      :status => "MyString",
      :institutional_LSID => "MyString",
      :is_index_herbariorum => false,
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit repository form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", repository_path(@repository), "post" do
      assert_select "input#repository_name[name=?]", "repository[name]"
      assert_select "input#repository_url[name=?]", "repository[url]"
      assert_select "input#repository_acronym[name=?]", "repository[acronym]"
      assert_select "input#repository_status[name=?]", "repository[status]"
      assert_select "input#repository_institutional_LSID[name=?]", "repository[institutional_LSID]"
      assert_select "input#repository_is_index_herbariorum[name=?]", "repository[is_index_herbariorum]"
    end
  end
end
