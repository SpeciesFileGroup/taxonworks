require 'rails_helper'

describe "public_contents/show", :type => :view do
  before(:each) do
    @public_content = assign(:public_content, stub_model(PublicContent,
      :otu_id => 1,
      :topic_id => 2,
      :text => "MyText",
      :project_id => 3,
      :created_by_id => 4,
      :updated_by_id => 5,
      :content_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
