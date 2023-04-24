require 'rails_helper'

RSpec.describe "coldp_profiles/new", type: :view do
  before(:each) do
    assign(:coldp_profile, ColdpProfile.new(
      title_alias: "MyString",
      project: nil,
      otu: nil,
      prefer_unlabelled_otu: false,
      checklistbank: 1,
      export_interval: "MyString"
    ))
  end

  it "renders new coldp_profile form" do
    render

    assert_select "form[action=?][method=?]", coldp_profiles_path, "post" do

      assert_select "input[name=?]", "coldp_profile[title_alias]"

      assert_select "input[name=?]", "coldp_profile[project_id]"

      assert_select "input[name=?]", "coldp_profile[otu_id]"

      assert_select "input[name=?]", "coldp_profile[prefer_unlabelled_otu]"

      assert_select "input[name=?]", "coldp_profile[checklistbank]"

      assert_select "input[name=?]", "coldp_profile[export_interval]"
    end
  end
end
