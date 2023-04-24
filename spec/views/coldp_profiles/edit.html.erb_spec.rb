require 'rails_helper'

RSpec.describe "coldp_profiles/edit", type: :view do
  before(:each) do
    @coldp_profile = assign(:coldp_profile, ColdpProfile.create!(
      title_alias: "MyString",
      project: nil,
      otu: nil,
      prefer_unlabelled_otu: false,
      checklistbank: 1,
      export_interval: "MyString"
    ))
  end

  it "renders the edit coldp_profile form" do
    render

    assert_select "form[action=?][method=?]", coldp_profile_path(@coldp_profile), "post" do

      assert_select "input[name=?]", "coldp_profile[title_alias]"

      assert_select "input[name=?]", "coldp_profile[project_id]"

      assert_select "input[name=?]", "coldp_profile[otu_id]"

      assert_select "input[name=?]", "coldp_profile[prefer_unlabelled_otu]"

      assert_select "input[name=?]", "coldp_profile[checklistbank]"

      assert_select "input[name=?]", "coldp_profile[export_interval]"
    end
  end
end
