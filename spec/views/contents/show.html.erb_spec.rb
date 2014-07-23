require 'rails_helper'

describe "contents/show", :type => :view do
  before(:each) do
    @content = assign(:content, stub_model(Content,
      :text => "MyText",
      :otu_id => 1,
      :topic_id => 2,
      :type => "Type",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5,
      :revision_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
