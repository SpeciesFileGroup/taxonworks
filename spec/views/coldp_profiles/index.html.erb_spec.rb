require 'rails_helper'

RSpec.describe "coldp_profiles/index", type: :view do
  before(:each) do
    assign(:coldp_profiles, [
      ColdpProfile.create!(
        title_alias: "Title Alias",
        project: nil,
        otu: nil,
        prefer_unlabelled_otu: false,
        checklistbank: 2,
        export_interval: "Export Interval"
      ),
      ColdpProfile.create!(
        title_alias: "Title Alias",
        project: nil,
        otu: nil,
        prefer_unlabelled_otu: false,
        checklistbank: 2,
        export_interval: "Export Interval"
      )
    ])
  end

  it "renders a list of coldp_profiles" do
    render
    assert_select "tr>td", text: "Title Alias".to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Export Interval".to_s, count: 2
  end
end
